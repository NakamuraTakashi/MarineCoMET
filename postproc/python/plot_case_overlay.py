#!/usr/bin/env python3
"""
Overlay the same variable from several experimental cases on one figure.

run_all.sh runs every case into a shared output directory, each with its own
OUTFILE_prefix, so the directory holds files named

    <case>-<file>.csv          e.g.  T15-L150-crl01_his.csv

For every requested variable this script draws one PNG with one line per
case and saves it to <output-dir>/plot_summary (or the folder given by -p).

Variables are requested as  <file>:<col>[,<col>...]
  - <file> is the part after '<case>-', e.g. crl01_his or crl01_ave.
    '_his' is appended when no '_his'/'_ave' suffix is given.
  - <col> is matched case-insensitively, and '/' and '_' are treated alike,
    so 'Fv_Fm' finds 'Fv/Fm' and 'chl' finds 'Chl'.

Examples
--------
    # every case found in output01
    python plot_case_overlay.py -o output01 -v crl01:Pg,Pn,G -v zphot01:Fv_Fm

    # only some cases, a 5-day window from day 50
    python plot_case_overlay.py -o output01 -v zoo01:dens \\
        -c T15-L400 T25-L400 T32-L400 -s 50 -d 5
"""

import argparse
import glob
import os
import re

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd


def _fmt_day(v):
    """Format a day value for use in file names ('180', '180.5')."""
    return f'{v:g}'


def _natural_key(s):
    """Sort key that orders 'T5' before 'T15'."""
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]


def _norm(name):
    return name.strip().lower().replace('/', '_')


def _parse_spec(spec):
    """'crl01:Pg,Pn' -> ('crl01_his', ['Pg', 'Pn'])."""
    if ':' not in spec:
        raise argparse.ArgumentTypeError(
            f"'{spec}': expected <file>:<col>[,<col>...], e.g. crl01:Pg,Pn")
    key, cols = spec.split(':', 1)
    key = key.strip()
    if not key.endswith(('_his', '_ave')):
        key += '_his'
    cols = [c.strip() for c in cols.split(',') if c.strip()]
    if not cols:
        raise argparse.ArgumentTypeError(f"'{spec}': no column names given")
    return key, cols


def _find_case_files(output_dir, key, cases=None):
    """Return {case: csv_path} for every '<case>-<key>.csv' in output_dir."""
    tail = f'-{key}.csv'
    found = {}
    for path in glob.glob(os.path.join(output_dir, f'*{tail}')):
        case = os.path.basename(path)[:-len(tail)]
        if cases is None or case in cases:
            found[case] = path
    return dict(sorted(found.items(), key=lambda kv: _natural_key(kv[0])))


def _read_csv(path):
    """Read a model CSV; None when it is empty (see plot_csv_timeseries.py)."""
    try:
        df = pd.read_csv(path, index_col=False)
    except pd.errors.EmptyDataError:
        return None
    if df.empty or len(df.columns) == 0:
        return None
    df.columns = df.columns.str.strip()
    df[df.columns[0]] = pd.to_numeric(df[df.columns[0]], errors='coerce')
    return df


_LINESTYLES = ['-', '--', ':', '-.']

# Fixed line style for known levels of the second factor; other levels fall
# back to _LINESTYLES in sorted order.
_LEVEL_LINESTYLES = {
    'L400': '-',              # solid
    'L150': (0, (3, 1)),      # densely dashed
    'L800': (0, (6, 2)),     # loosely dashed
}


def _case_styles(cases):
    """Return {case: (colour, linestyle)}.

    Case names made of two factors, like 'T15-L400', get colour by the first
    factor and line style by the second, so a temperature x light design reads
    at a glance.  Anything else gets one distinct colour per case.
    """
    parts = [c.split('-') for c in cases]
    if len(cases) > 1 and all(len(p) == 2 for p in parts):
        f1 = sorted({p[0] for p in parts}, key=_natural_key)
        f2 = sorted({p[1] for p in parts}, key=_natural_key)
        if len(f1) <= 10 and len(f2) <= len(_LINESTYLES):
            # turbo runs blue -> red without coolwarm's washed-out middle.
            cmap = plt.get_cmap('turbo')
            col = {v: cmap(0.1 + 0.8 * i / max(len(f1) - 1, 1))
                   for i, v in enumerate(f1)}
            ls = {v: _LEVEL_LINESTYLES.get(v, _LINESTYLES[i])
                  for i, v in enumerate(f2)}
            return {c: (col[p[0]], ls[p[1]]) for c, p in zip(cases, parts)}
    if len(cases) <= 20:
        cmap = plt.get_cmap('tab10' if len(cases) <= 10 else 'tab20')
        return {c: (cmap(i), '-') for i, c in enumerate(cases)}
    cmap = plt.get_cmap('viridis')
    return {c: (cmap(i / (len(cases) - 1)), '-') for i, c in enumerate(cases)}


def plot_case_overlay(output_dir, specs, plot_output_dir=None, cases=None,
                      start=None, duration=None):
    """Draw one overlay PNG per requested variable.

    Returns the number of figures written.
    """
    if plot_output_dir is None:
        plot_output_dir = os.path.join(output_dir, 'plot_summary')
    os.makedirs(plot_output_dir, exist_ok=True)

    do_zoom = (start is not None) or (duration is not None)
    n_written = 0

    for key, cols in specs:
        files = _find_case_files(output_dir, key, cases)
        if not files:
            print(f'No *-{key}.csv files in {output_dir} - skipped')
            continue
        frames = {}
        for case, path in files.items():
            df = _read_csv(path)
            if df is None:
                print(f'  Skipping (empty): {os.path.basename(path)}')
                continue
            frames[case] = df
        if not frames:
            continue
        styles = _case_styles(list(frames))
        print(f'{key}: {len(frames)} case(s)')

        for col in cols:
            fig, ax = plt.subplots(figsize=(11, 5))
            col_label = None
            t0 = t1 = None
            n_lines = 0
            for case, df in frames.items():
                match = [c for c in df.columns if _norm(c) == _norm(col)]
                if not match:
                    print(f'  Warning: {case}-{key}.csv has no column {col!r}')
                    continue
                col_label = match[0]
                time_col = df.columns[0]
                if do_zoom:
                    t0 = df[time_col].min() if start is None else start
                    t1 = df[time_col].max() if duration is None else t0 + duration
                    df = df[(df[time_col] >= t0) & (df[time_col] <= t1)]
                    if df.empty:
                        continue
                ax.plot(df[time_col], pd.to_numeric(df[col_label], errors='coerce'),
                        linewidth=1, color=styles[case][0],
                        linestyle=styles[case][1], label=case)
                n_lines += 1

            if n_lines == 0:
                print(f'  {col}: nothing to plot')
                plt.close(fig)
                continue

            title_extra = suffix = ''
            if do_zoom:
                title_extra = f'  [day {_fmt_day(t0)} - {_fmt_day(t1)}]'
                suffix = f'_d{_fmt_day(t0)}-{_fmt_day(t1)}'
            ax.set_xlabel(time_col)
            ax.set_ylabel(col_label)
            ax.set_title(f'{key} - {col_label}{title_extra}')
            ax.grid(True, alpha=0.3)
            ax.legend(loc='upper left', bbox_to_anchor=(1.01, 1.0),
                      fontsize='small', frameon=False)

            col_safe = col_label.replace('/', '_').replace(' ', '_')
            filename = f'{key}_{col_safe}{suffix}.png'
            fig.savefig(os.path.join(plot_output_dir, filename),
                        dpi=100, bbox_inches='tight')
            plt.close(fig)
            n_written += 1
            print(f'  {col_label}: {n_lines} case(s) -> {filename}')

    print(f'Wrote {n_written} figure(s) to {plot_output_dir}')
    return n_written


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Overlay one variable from several MarineCoMET cases',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            'Examples:\n'
            '  %(prog)s -o output01 -v crl01:Pg,Pn,G -v zphot01:Fv_Fm\n'
            '  %(prog)s -o output01 -v zoo01:dens -c T15-L400 T25-L400 -s 50 -d 5\n'
        ),
    )
    parser.add_argument(
        '-o', '--output-dir', default='output',
        help='Directory containing the cases\' CSV files (default: output)')
    parser.add_argument(
        '-p', '--plot-output-dir', default=None,
        help='Directory for the overlay plots (default: <output-dir>/plot_summary)')
    parser.add_argument(
        '-v', '--var', dest='specs', action='append', type=_parse_spec,
        required=True, metavar='FILE:COL[,COL...]',
        help='Variables to overlay, e.g. crl01:Pg,Pn,G (repeatable)')
    parser.add_argument(
        '-c', '--cases', nargs='+', default=None,
        help='Only these cases (default: every case found in the directory)')
    parser.add_argument(
        '-s', '--start', type=float, default=None,
        help='First day of a zoom window (default: whole run)')
    parser.add_argument(
        '-d', '--duration', type=float, default=None,
        help='Length of the zoom window in days')

    args = parser.parse_args()

    plot_case_overlay(
        output_dir=args.output_dir,
        specs=args.specs,
        plot_output_dir=args.plot_output_dir,
        cases=set(args.cases) if args.cases else None,
        start=args.start,
        duration=args.duration,
    )
