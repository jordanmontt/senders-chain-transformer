Class {
	#name : 'AllocationGraphTest',
	#superclass : 'TestCase',
	#instVars : [
		'samples',
		'allocationGraph'
	],
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'running' }
AllocationGraphTest >> setUp [

	| profiler |
	super setUp.
	profiler := IllMemoryProfiler new
		            samplingRate: 1;
		            profileOn: [ AllocationGraphFixture entryPoint ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
		           { Array. Behavior } includes: ephemeron allocatedObjectClass ].
	allocationGraph := AllocationGraph new
		                   setUpForSamples: samples;
		                   yourself.
]

{ #category : 'tests' }
AllocationGraphTest >> testBuildSubgraphFromMethod [

	allocationGraph := allocationGraph buildSubgraphFromMethod: AllocationGraphFixture class >> #entryPoint.
	self assert: allocationGraph nodes size equals: 11
]

{ #category : 'tests' }
AllocationGraphTest >> testLeaves [

	| expectedLeaveSelectors |
	expectedLeaveSelectors := { #basicNew. #new:. #basicNewTenured }.
	self assert: allocationGraph leaves size equals: 3.
	self
		assertCollection: (allocationGraph leaves collect: [ :e | e method selector ])
		hasSameElements: expectedLeaveSelectors
]
