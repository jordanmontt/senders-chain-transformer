# Senders Chain Transformer

A Pharo tool that modifies the execution path for a given calling context by **monomorphizing a chain of senders**. Given an initial caller and a list of senders along a call path, the tool duplicates each method in the chain under a fresh selector and rewires the message sends so that the new path executes only when entered through the chosen entry point. Every other caller of the original methods is left intact.

This makes it possible to specialize the behavior of a method only for a specific calling context — for example, to apply a transformation, an instrumentation, or an optimization to a leaf method (such as a primitive allocator) only when it is reached through a particular path in the call graph.

## Motivation

In pure object-oriented languages such as Pharo, many methods are reused across many calling contexts. A leaf method like `Behavior >> #basicNew` is reached from virtually every higher-level allocator method, which itself is reached from many factory methods, which are in turn reached from many callers. Specializing the leaf for one specific caller without affecting the others is non-trivial: simply editing the leaf would change behavior for every caller, and editing only the entry point is not enough because the specialization typically needs to take effect deep in the call chain.

The Senders Chain Transformer addresses this by *monomorphizing* the chain: it produces an isolated copy of every method along the chosen path, connected only by the new selectors. Calls that enter the chain through other paths continue to use the original methods. This is the rewriting backend used in the **path-sensitive pretenuring** approach described in:

> Sebastian Jordan Montaño. *Memory Profiling in Dynamic Languages*. PhD thesis, Université de Lille / Inria, 2026.

In that work, the tool is applied to long-lived sender chains identified from object-lifetime profiling, so that allocations are pretenured only when reached through chains that demonstrably allocate long-lived objects.

## How it works

The transformer takes:

- an **initial caller** — a method that performs the first message send in the chain to be specialized;
- an **ordered list of senders** — the methods reached from the initial caller down to the leaf;
- a **new selector** prefix (or strategy) used to generate the unique selectors of the duplicated methods.

For each method along the chain, the tool:

1. Clones the method.
2. Renames the clone with a unique selector.
3. Rewrites the clone's outgoing message send so that it targets the next clone in the chain.

The initial caller's message send is rewritten to target the first clone. The original methods remain unchanged and continue to serve all other calling contexts. Because the clones are regular `CompiledMethod` objects, they are fully compatible with virtual machine optimizations such as polymorphic inline caches and JIT compilation.

## Example

Consider an allocation site `#allocSite:` that ultimately allocates an `Association` through the following chain of senders:

```
#allocSite:
   ↓
Dictionary >> #at:ifAbsentPut:
   ↓
Dictionary >> #at:ifAbsent:
   ↓
Dictionary >> #at:put:
   ↓
Association class >> #key:value:
   ↓
Behavior >> #basicNew     (allocation)
```

After running the transformer with `#allocSite:` as the initial caller and the chain above as the list of senders, a parallel set of methods is installed (e.g., `#pretenured_at:ifAbsentPut:`, `#pretenured_at:ifAbsent:`, `#pretenured_at:put:`, `#pretenured_key:value:`, `#pretenured_basicNew`). The original `#allocSite:` method is rewritten to call the first specialized selector, and each clone calls the next clone in the chain.

Allocations that flow through `#allocSite:` now traverse the specialized path, while all other callers of `Dictionary >> #at:ifAbsentPut:`, `Association class >> #key:value:`, etc. are unaffected.

## How to install

```smalltalk
EpMonitor disableDuring: [
    Metacello new
        baseline: 'SendersChainTransformer';
        repository: 'github://jordanmontt/senders-chain-transformer:main';
        load ].
```

## Use cases

- **Path-sensitive pretenuring**: replace the leaf primitive allocator with a pretenuring variant only along long-lived call chains.
- **Context-sensitive instrumentation**: insert measurement code into a method only when it is invoked from a specific call path.
- **Per-context specialization**: apply alternative implementations (faster, instrumented, debug-enabled) of a shared method to a single caller without touching the rest of the system.

## Related projects

- [Illimani Memory Profiler](https://github.com/jordanmontt/illimani-memory-profiler) — the memory profiler whose object-lifetime samples drive path-sensitive pretenuring.
- [Pretenuring Advice Algorithm](https://github.com/jordanmontt/Pretenuring-Advice-Algorithm) — the GC-agnostic algorithm used to classify allocation sites along sender chains.
- [MethodProxies](https://github.com/pharo-contributions/MethodProxies) — the underlying meta-safe instrumentation library used to capture allocations.

## License

MIT
