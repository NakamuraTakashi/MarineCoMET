# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "xarray",
#     "netcdf4",
#     "matplotlib",
#     "numpy",
# ]
# ///
"""Animate yearly-maximum DHW and DCW from a CDO yearmax NetCDF file.

Usage:
    uv run animate_dhw_dcw.py [input.nc] [-o out.mp4] [--fps 4] [--dpi 120]

The output format follows the extension of -o (.mp4 uses ffmpeg, .gif uses pillow).
"""

import argparse

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr
from matplotlib import animation

DEFAULT_NC = "yearmax_DHW_DCW_19600101.0000-20201231.0000.nc"

# variable: (colormap, vmax, colorbar label, title)
PANELS = {
    "DHW": ("hot_r", 16.0, "DHW (°C-week)", "Annual max Degree Heating Week"),
    "DCW": ("Blues", 100.0, "DCW (°C-week)", "Annual max Degree Cooling Week"),
}

# variable: [(level, color), ...] contour lines drawn on top of each panel
CONTOURS = {
    "DHW": [(8.0, "deepskyblue")],
    "DCW": [(20.0, "darkorange"), (80.0, "red")],
}


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("nc", nargs="?", default=DEFAULT_NC)
    p.add_argument("-o", "--output", default="yearmax_DHW_DCW.mp4")
    p.add_argument("--fps", type=int, default=4)
    p.add_argument("--dpi", type=int, default=120)
    args = p.parse_args()

    ds = xr.open_dataset(args.nc)
    lon, lat = ds.lon.values, ds.lat.values
    years = ds.time.dt.year.values

    fig, axes = plt.subplots(1, len(PANELS), figsize=(13, 5.6), layout="constrained")
    meshes = {}
    panel_axes = {}
    for ax, (name, (cmap, vmax, label, title)) in zip(axes, PANELS.items()):
        cm = plt.get_cmap(cmap).copy()
        cm.set_bad("0.75")  # land / fill values in gray
        mesh = ax.pcolormesh(
            lon, lat, ds[name].isel(time=0).values,
            cmap=cm, vmin=0.0, vmax=vmax, shading="auto",
        )
        fig.colorbar(mesh, ax=ax, label=label, extend="max", shrink=0.85)
        ax.set_title(title)
        ax.set_xlabel("Longitude (°E)")
        ax.set_ylabel("Latitude (°N)")
        ax.set_aspect(1.0 / np.cos(np.deg2rad(lat.mean())))
        meshes[name] = mesh
        panel_axes[name] = ax
    # Reserve a top band for the year label and place it there ourselves
    # (fig.suptitle leaves a large gap under constrained layout).
    fig.get_layout_engine().set(rect=(0, 0, 1, 0.96))
    suptitle = fig.text(0.5, 0.94, str(years[0]), ha="center", va="center",
                        fontsize=16, fontweight="bold")

    contour_sets = []

    def draw_contours(name, data):
        levels = CONTOURS.get(name)
        if not levels:
            return
        contour_sets.append(panel_axes[name].contour(
            lon, lat, data,
            levels=[lv for lv, _ in levels], colors=[c for _, c in levels],
            linewidths=1.2,
        ))

    def update(i):
        # Contour sets cannot be updated in place, so redraw them every frame.
        while contour_sets:
            contour_sets.pop().remove()
        for name, mesh in meshes.items():
            data = ds[name].isel(time=i).values
            mesh.set_array(data.ravel())
            draw_contours(name, data)
        suptitle.set_text(str(years[i]))
        print(f"\rframe {i + 1}/{len(years)}", end="", flush=True)
        return [*meshes.values(), *contour_sets, suptitle]

    anim = animation.FuncAnimation(fig, update, frames=len(years), blit=False)
    if args.output.lower().endswith(".gif"):
        writer = animation.PillowWriter(fps=args.fps)
    else:
        # No B-frames: Windows Media Player otherwise drops the last frames.
        writer = animation.FFMpegWriter(
            fps=args.fps, codec="libx264",
            extra_args=["-pix_fmt", "yuv420p", "-bf", "0"],
        )
    anim.save(args.output, writer=writer, dpi=args.dpi)
    print(f"\nsaved: {args.output}")


if __name__ == "__main__":
    main()
