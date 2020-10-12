# Alpaca-Case

Laser cut case for Alpaca.

## Usage

- Don't forget to checkout all submodules by using `git submodule update --init --recursive`.
- Export the cutting (set `ENGRAVE=false`) and engraving (set `ENGRAVE=true`) profiles as DXF (via Customizer GUI or command line).
- Cut one sheet using the exported **cutting** profile.
- Engrave the same sheet using the exported **engraving** profile (beware of the alignment).
- Repeat the process using required materials until done.
- Print out all additional required parts in `models.scad` using a 3D printer.

### Customizer

The OpenSCAD Customizer is used in this project as a quick, non-invasive way to preview the design (in both 2D profile and assembled 3D model) and to simplify the build process. See the description fields in Customizer regarding to the usage of each options.

### laserscad

**NOTE**: laserscad does not support paging shapes across multiple sheets (i.e. multi bin packing) yet. So this option does not do much at this point.

To use laserscad support, run

```sh
pushd ext/laserscad/dist
make cut OFLAGS='-D SHEET='"'"'"lscad"'"'"'' model=../../../case.scad
popd
```
