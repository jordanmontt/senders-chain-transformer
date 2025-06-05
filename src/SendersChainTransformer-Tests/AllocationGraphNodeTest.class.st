"
An AllocationGraphNodeTest is a test class for testing the behavior of AllocationGraphNode
"
Class {
	#name : 'AllocationGraphNodeTest',
	#superclass : 'TestCase',
	#instVars : [
		'allocationGraph',
		'profiler'
	],
	#category : 'SendersChainTransformer-Tests-Allocation-Graph',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Allocation-Graph'
}

{ #category : 'running' }
AllocationGraphNodeTest >> setUp [

	| samples |
	super setUp.
	profiler := IllMemoryProfiler new
		            samplingRate: 1;
		            profileOn: [ AllocationGraphFixture entryPoint ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
			           {
				           Array.
				           Behavior } includes: ephemeron allocatedObjectClass ].
	allocationGraph := AllocationGraph onSamples: samples.
	allocationGraph := allocationGraph pruneFromRoot:
		                   (allocationGraph nodeAtMethod:
			                    AllocationGraphFixture class >> #entryPoint)
]

{ #category : 'tests' }
AllocationGraphNodeTest >> testPathToCaller [

	| actualPaths expectedPaths |
	
	actualPaths := allocationGraph
			allReversedPathsFrom: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7)
			to: (allocationGraph nodeAtMethod: Behavior >> #basicNewTenured).
	expectedPaths := {
		                 {
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7).
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5).
			                 (allocationGraph nodeAtMethod: Behavior >> #basicNewTenured) }.
		                 {
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7).
			                 (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4).
			                 (allocationGraph nodeAtMethod: Behavior >> #basicNewTenured) } }.

	self assert: actualPaths size equals: 2.
	self assertCollection: actualPaths includesAll: expectedPaths.
]
