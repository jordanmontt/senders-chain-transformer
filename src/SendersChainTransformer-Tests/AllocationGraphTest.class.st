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
AllocationGraphTest >> testAllocationSiteDetectionAfterPruning [

	allocationGraph := allocationGraph pruneGraphFromNewRoot: AllocationGraphFixture class >> #entryPoint.
	allocationGraph identifyAllocationSitesUsing: TextualLocationOfNewStrategy new.

	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m2) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
AllocationGraphTest >> testAllocationSiteDetectionAfterPruningMethodInPackage [

	allocationGraph := allocationGraph pruneGraphFromNewRoot: AllocationGraphFixture class >> #entryPoint.
	allocationGraph identifyAllocationSitesUsing:
		(MethodFromTheSamePackageStrategy packagesToMatch: { self class package }).

	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m2) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAt: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
AllocationGraphTest >> testDetectAllocationSiteDefault [

	allocationGraph identifyAllocationSitesUsing: TextualLocationOfNewStrategy new.

	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m2) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
AllocationGraphTest >> testDetectAllocationSitesUsingMethodInPackage [

	allocationGraph identifyAllocationSitesUsing:
		(MethodFromTheSamePackageStrategy packagesToMatch: { self class package }).

	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m2) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAt: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAt: AllocationGraphFixture class >> #entryPoint) isAllocationSite
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
	self assert: allocationGraph nodes size equals: 12.
	
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #entryPoint) allocatedSamples size equals: 60.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m6) allocatedSamples size equals: 50.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m7) allocatedSamples size equals: 10.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m2) allocatedSamples size equals: 5.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m1) allocatedSamples size equals: 25.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m3) allocatedSamples size equals: 20.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m4) allocatedSamples size equals: 5.
	self assert: (allocationGraph nodeAt: AllocationGraphFixture class >> #m5) allocatedSamples size equals: 5.
	
	self assert: (allocationGraph nodeAt: AllocationGraphFixtureUtilities class >> #mm) allocatedSamples size equals: 5.
	
	self assert: (allocationGraph nodeAt: Behavior >> #basicNew) allocatedSamples size equals: 10.
	self assert: (allocationGraph nodeAt: Behavior >> #basicNewTenured) allocatedSamples size equals: 30.
	self assert: (allocationGraph nodeAt: Array class >> #new:) allocatedSamples size equals: 20
]
