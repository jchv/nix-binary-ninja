{ pkgs, nodes }:
pkgs.testers.nixosTest {
  inherit nodes;
  name = "binary-ninja-simple";
  enableOCR = true;
  testScript =
    { nodes, ... }:
    let
      user = nodes.machine.users.users.alice;
    in
    ''
      machine.wait_for_x()
      machine.wait_for_file("${user.home}/.Xauthority")
      machine.succeed("xauth merge ${user.home}/.Xauthority")

      with subtest("Wait until Binary Ninja starts up"):
        machine.execute("su - alice -c 'xterm -e binaryninja' >&2 &")
        machine.wait_for_window("Binary Ninja Free")
        machine.sleep(1)
        machine.send_key("ret")
        machine.sleep(1)
        machine.send_key("esc")
        machine.sleep(1)

      with subtest("Open /bin/sh and wait for disassembly"):
        machine.send_key("ctrl-l")
        machine.sleep(1)
        machine.send_chars("file:///bin/sh\n")
        machine.wait_for_text("_start")
    '';
}
