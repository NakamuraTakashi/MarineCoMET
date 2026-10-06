#!/usr/bin/env python3
"""
Plot time series data from MarineCoMET simulation CSV files.
Each column is plotted separately.

Two kinds of output can be produced in a single run:

  1. Full period   - the whole time axis (default)
  2. Zoom window   - an arbitrary start day and duration, e.g. 3 days from day 180
                     (enabled by --start and/or --duration)

The destination folder of each kind can be set independently.

Examples
--------
    # full period only (default behaviour)
    python plot_csv_timeseries.py -o output01

    # full period + a 3-day window starting at day 180
    python plot_csv_timeseries.py -o output01 -s 180 -d 3

    # window only, into a named folder
    python plot_csv_timeseries.py -o output01 --no-full -s 180 -d 3 -z output01/plots_diel
"""

import argparse
import os

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd


def _fmt_day(v):
    """Format a day value for use in file names ('180', '180.5')."""
    return f'{v:g}'


def _plot_dataframe(df, time_col, csv_stem, plot_output_dir, suffix='', title_extra=''):
    """Plot every non-time column of `df` into `plot_output_dir`.

    Returns the number of columns plotted.
    """
    os.makedirs(plot_output_dir, exist_ok=True)

    plot_count = 0
    for col in df.columns:
        if col == time_col:
            continue

        series = pd.to_numeric(df[col], errors='coerce')
        if series.isna().all():
            continue

        fig, ax = plt.subplots(figsize=(10, 5))
        try:
            ax.plot(df[time_col], series, linewidth=1)
            ax.set_xlabel(time_col)
            ax.set_ylabel(col)
            ax.set_title(f'{csv_stem} - {col}{title_extra}')
            ax.grid(True, alpha=0.3)

            col_safe = col.replace('/', '_').replace(' ', '_')
            filename = f'{csv_stem}_{col_safe}{suffix}.png'
            fig.savefig(os.path.join(plot_output_dir, filename),
                        dpi=100, bbox_inches='tight')
            plot_count += 1
        except Exception as e:                       # noqa: BLE001 - keep going on bad columns
            print(f"  Warning: Could not plot '{col}': {e}")
        finally:
            plt.close(fig)

    return plot_count


def plot_csv_timeseries(output_dir=None, plot_output_dir=None,
                        start=None, duration=None, zoom_output_dir=None,
                        plot_full=True):
    """Plot time series data from MarineCoMET CSV files.

    Parameters
    ----------
    output_dir : str
        Directory containing CSV files (default: 'output').
    plot_output_dir : str
        Directory for the full-period plots (default: <output_dir>/plots).
    start : float or None
        First day of the zoom window. Defaults to the first day in the file
        when only `duration` is given.
    duration : float or None
        Length of the zoom window in days. Defaults to the end of the file
        when only `start` is given.
    zoom_output_dir : str or None
        Directory for the zoom-window plots
        (default: <output_dir>/plots_d<start>-<end>).
    plot_full : bool
        Whether to produce the full-period plots.
    """
    if output_dir is None:
        output_dir = 'output'

    if plot_output_dir is None:
        plot_output_dir = os.path.join(output_dir, 'plots')

    do_zoom = (start is not None) or (duration is not None)

    if not plot_full and not do_zoom:
        print('Nothing to do: --no-full was given without --start/--duration')
        return

    csv_files = [f for f in os.listdir(output_dir) if f.endswith('.csv')]
    if not csv_files:
        print(f'No CSV files found in {output_dir}')
        return

    print(f'Found {len(csv_files)} CSV files')
    if plot_full:
        print(f'Full-period plots : {plot_output_dir}')
    if do_zoom:
        print(f'Zoom window       : start={start}, duration={duration}')
    print()

    for csv_file in sorted(csv_files):
        csv_path = os.path.join(output_dir, csv_file)
        csv_stem = csv_file[:-4] if csv_file.endswith('.csv') else csv_file

        # An output file can legitimately be empty: the model opens one CSV per
        # coral type regardless of coverage, so a type with p_coral_0 = 0 is never
        # computed and leaves a 0-byte file behind.  A run killed part-way leaves
        # the same thing.  pandas raises EmptyDataError on those, which used to
        # abort the whole loop - and because the files are processed in sorted
        # order, an empty crl02 stopped ecosys and env from ever being plotted.
        try:
            df = pd.read_csv(csv_path)
        except pd.errors.EmptyDataError:
            print(f'Skipping (empty): {csv_file}')
            print()
            continue
        if df.empty or len(df.columns) == 0:
            print(f'Skipping (no rows): {csv_file}')
            print()
            continue
        df.columns = df.columns.str.strip()

        # The time axis is the first column ('time' in days for *_his.csv,
        # 'day' for *_ave.csv).
        time_col = df.columns[0]
        df[time_col] = pd.to_numeric(df[time_col], errors='coerce')

        print(f'Processing: {csv_file}')
        print(f'  Columns: {len(df.columns)}')
        print(f'  Rows: {len(df)}')

        if plot_full:
            n = _plot_dataframe(df, time_col, csv_stem, plot_output_dir)
            print(f'  Full period : plotted {n} columns')

        if do_zoom:
            t0 = df[time_col].min() if start is None else start
            t1 = df[time_col].max() if duration is None else t0 + duration

            window = df[(df[time_col] >= t0) & (df[time_col] <= t1)]
            if window.empty:
                print(f'  Zoom window : no data in [{_fmt_day(t0)}, {_fmt_day(t1)}] - skipped')
            else:
                zoom_dir = zoom_output_dir
                if zoom_dir is None:
                    zoom_dir = os.path.join(
                        output_dir, f'plots_d{_fmt_day(t0)}-{_fmt_day(t1)}')
                suffix = f'_d{_fmt_day(t0)}-{_fmt_day(t1)}'
                title_extra = f'  [day {_fmt_day(t0)} - {_fmt_day(t1)}]'
                n = _plot_dataframe(window, time_col, csv_stem, zoom_dir,
                                    suffix=suffix, title_extra=title_extra)
                print(f'  Zoom window : plotted {n} columns '
                      f'({len(window)} rows) -> {zoom_dir}')

        print()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Plot time series data from MarineCoMET CSV files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            'Examples:\n'
            '  %(prog)s -o output01\n'
            '  %(prog)s -o output01 -s 180 -d 3\n'
            '  %(prog)s -o output01 --no-full -s 180 -d 3 -z output01/plots_diel\n'
        ),
    )
    parser.add_argument(
        '-o', '--output-dir', default='output',
        help='Directory containing CSV files (default: output)')
    parser.add_argument(
        '-p', '--plot-output-dir', default=None,
        help='Directory for full-period plots (default: <output-dir>/plots)')
    parser.add_argument(
        '-s', '--start', type=float, default=None,
        help='First day of the zoom window (default: first day in the file)')
    parser.add_argument(
        '-d', '--duration', type=float, default=None,
        help='Length of the zoom window in days (default: to the end of the file)')
    parser.add_argument(
        '-z', '--zoom-output-dir', default=None,
        help='Directory for zoom-window plots '
             '(default: <output-dir>/plots_d<start>-<end>)')
    parser.add_argument(
        '--no-full', action='store_true',
        help='Skip the full-period plots (zoom window only)')

    args = parser.parse_args()

    plot_output_dir = args.plot_output_dir
    if plot_output_dir is None:
        plot_output_dir = os.path.join(args.output_dir, 'plots')

    plot_csv_timeseries(
        output_dir=args.output_dir,
        plot_output_dir=plot_output_dir,
        start=args.start,
        duration=args.duration,
        zoom_output_dir=args.zoom_output_dir,
        plot_full=not args.no_full,
    )
