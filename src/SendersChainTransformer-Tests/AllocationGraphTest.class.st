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
AllocationGraphTest >> testAllocationSiteDefaultDetection [
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

{ #category : 'tests' }
AllocationGraphTest >> testPruneGraphFromNewRoot [

	allocationGraph := allocationGraph pruneGraphFromNewRoot: AllocationGraphFixture class >> #entryPoint.
	self assert: allocationGraph nodes size equals: 11.
	
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #entryPoint) numberOfCalls equals: 60.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m6) numberOfCalls equals: 50.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m7) numberOfCalls equals: 10.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m2) numberOfCalls equals: 5.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m1) numberOfCalls equals: 25.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m3) numberOfCalls equals: 20.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m4) numberOfCalls equals: 5.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m5) numberOfCalls equals: 5.
	
	self assert: (allocationGraph nodeAt: Behavior >> #basicNew) numberOfCalls equals: 10.
	self assert: (allocationGraph nodeAt: Behavior >> #basicNewTenured) numberOfCalls equals: 30.
	self assert: (allocationGraph nodeAt: Array class >> #new:) numberOfCalls equals: 20
]
