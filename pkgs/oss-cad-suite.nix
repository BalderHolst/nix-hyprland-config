{ pkgs ? import <nixpkgs> { } }:
let 
    yosys-with-ghdl = pkgs.stdenv.mkDerivation {
        name = "yosys-with-ghdl";
        src = pkgs.yosys;

        installPhase = ''
            mkdir -p $out/bin
            ln -sv ${pkgs.yosys}/bin/yosys $out/bin/yosys
            mkdir -p $out/share/yosys/plugins
            cp -rfv ${pkgs.yosys-ghdl}/share/yosys/plugins/ghdl.so $out/share/yosys/plugins/ghdl.so
            '';
    };

    bin-programs = with pkgs; [
        yosys-with-ghdl
        ghdl
        python311Packages.amaranth
        # python311Packages.migen
        abc-verifier

        symbiyosys # formal verification
        # symbiyosys gui 
        mcy
        # eqy
        aiger
        avy
        boolector
        # Yices 2 
        # Super prove
        # Pono
        z3
        bitwuzla
        nextpnr
        nextpnrWithGui
        icestorm
        trellis        
        # Project Oxide
        # Project Apicula 

        openfpgaloader # flashing tool
        dfu-util
        # ecpprog 
        ecpdap
        fujprog 
        openocd 
        # icesprog 
        # TinyFPGA 
        # TinyFPGA-B 
        # iceFUN

        gaw
        verilator
        verilog
        python311Packages.cocotb
        gtkwave
    ];
in
pkgs.stdenv.mkDerivation {

    name = "oss-cad-suite";

    unpackPhase = "true"; # No src


    installPhase =
    let
        copy-cmds = builtins.concatStringsSep "\n" (builtins.map (x:
        ''
        for b in $(ls ${x}/bin); do
            [[ -e $out/bin/$b ]] || ln -sv ${x}/bin/$b $out/bin/$b
        done
        ''
        ) bin-programs);
    in
    ''
    mkdir -p $out/bin
    ${copy-cmds}
    '';
}
