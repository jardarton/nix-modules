"""Exercise the angr stack without external binaries or network access."""

import angr
import archinfo
import cle
import pyvex
from angr import claripy, rustylib

assert len({module.__version__ for module in (angr, archinfo, cle, pyvex)}) == 1
assert rustylib is not None

# Execute only MOV EAX, 42; do not execute RET with an uninitialized stack.
project = angr.load_shellcode(bytes.fromhex("b82a000000c3"), arch="amd64")
state = project.factory.blank_state()
successors = project.factory.successors(state, num_inst=1)
assert len(successors.flat_successors) == 1
assert successors.flat_successors[0].solver.eval(successors.flat_successors[0].regs.eax) == 42

value = claripy.BVS("value", 32)
solver = claripy.Solver()
solver.add(value + 1 == 42)
assert list(solver.eval(value, 1)) == [41]
print("angr: aligned imports, Rust extension, execution, and symbolic solving passed")
