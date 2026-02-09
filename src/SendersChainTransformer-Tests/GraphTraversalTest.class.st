Class {
	#name : 'GraphTraversalTest',
	#superclass : 'TestCase',
	#instVars : [
		'allocationGraph'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
}

{ #category : 'running' }
GraphTraversalTest >> setUp [

	| profiler samples |
	super setUp.
	profiler := FiLiP new
		            samplingRate: 1;
		            profileOn: [ AllocationGraphFixture entryPoint ];
		            yourself.
	samples := profiler objectAllocations select: [ :ephemeron |
		           { AllocationGraphFixtureElement . AllocationGraphFixtureArray } includes: ephemeron allocatedObjectClass ].
	allocationGraph := AllocationGraph new
		                   setUpForSamples: samples;
		                   yourself.
	
	allocationGraph edges do: #beLongLived.
]

{ #category : 'tests' }
GraphTraversalTest >> testAllPathsFromTo [

	| actualPaths expectedPaths |
	
	actualPaths := allocationGraph
			allPathsFrom: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7)
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

{ #category : 'tests' }
GraphTraversalTest >> testAllocationCallStackMatchesPath [

	| m2Node basicNewNode expectedPath allocationCallStack |
	allocationGraph identifyAllocationSitesUsing:
		(DefaultStrategy applicationPackages: { AllocationGraphFixture package }).

	m2Node := allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2.
	basicNewNode := allocationGraph nodeAtMethod: Behavior >> #basicNew.
	expectedPath := (allocationGraph allPathsFrom: m2Node to: basicNewNode) first.
	allocationCallStack := m2Node allocationCallStacks first reversed.
	
	self assert: allocationCallStack first sourceNode equals: expectedPath first.
	self assert: allocationCallStack first targetNode equals: expectedPath second.
	self assert: allocationCallStack second targetNode equals: expectedPath third
]

{ #category : 'tests' }
GraphTraversalTest >> testAllocationSiteDetectionAfterPruning [

	allocationGraph := allocationGraph pruneFromRoot: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint).
	allocationGraph identifyAllocationSitesUsing: TextualLocationOfNewStrategy new.

	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
GraphTraversalTest >> testAllocationSiteDetectionAfterPruningMethodInPackage [

	allocationGraph := allocationGraph pruneFromRoot: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint).
	allocationGraph identifyAllocationSitesUsing:
		(DefaultStrategy applicationPackages: { AllocationGraphFixture package }).

	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
GraphTraversalTest >> testDetectAllocationSiteDefault [

	allocationGraph identifyAllocationSitesUsing: TextualLocationOfNewStrategy new.

	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.	
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
GraphTraversalTest >> testDetectAllocationSitesUsingMethodInPackage [

	allocationGraph identifyAllocationSitesUsing:
		(DefaultStrategy applicationPackages: { AllocationGraphFixture package }).

	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m1) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m2) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m3) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m4) isAllocationSite.
	self assert: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m5) isAllocationSite.

	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixtureUtilities class >> #mm) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) isAllocationSite.
	self deny: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) isAllocationSite
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseLongLivedSenderChains [

	| sendersChains expectedSendersChains|
	allocationGraph edges do: #beShortLived.
	allocationGraph := allocationGraph pruneFromRoot: (allocationGraph nodeAtMethod: (AllocationGraphFixture class >> #entryPoint)).
	expectedSendersChains := OrderedCollection new.

	expectedSendersChains add: {
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m1 to: Behavior >> #basicNew).
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m6 to: AllocationGraphFixture class >> #m1) }.
	expectedSendersChains add: {
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m5 to: Behavior >> #basicNewTenured).
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m7 to: AllocationGraphFixture class >> #m5) }.
	expectedSendersChains add: {
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m4 to: Behavior >> #basicNewTenured).
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m7 to: AllocationGraphFixture class >> #m4) }.
	expectedSendersChains do: [ :col | col do: #beLongLived ].

	(allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m6) beAllocationSite.
	(allocationGraph nodeAtMethod: AllocationGraphFixture class >> #m7) beAllocationSite.

	allocationGraph traverseLongLivedSenderChainsUsing: NodeBasedAllocationSiteStrategy new.
	sendersChains := (allocationGraph nodes select: #isAllocationSite) flatCollect: #allocationCallStacks.

	self assert: expectedSendersChains size equals: sendersChains size.
	self assertCollection: expectedSendersChains hasSameElements: sendersChains
]

{ #category : 'tests' }
GraphTraversalTest >> testTraverseLongLivedSenderChainsLongChain [

	| sendersChain expectedSendersChain |
	allocationGraph edges do: #beShortLived.
	allocationGraph pruneFromRoot: (allocationGraph nodeAtMethod: (AllocationGraphFixture class >> #entryPoint)).
	expectedSendersChain := OrderedCollection new.

	expectedSendersChain addAll: {
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m4 to: Behavior >> #basicNewTenured).
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #m7 to: AllocationGraphFixture class >> #m4).
		(allocationGraph edgeFrom: AllocationGraphFixture class >> #entryPoint to: AllocationGraphFixture class >> #m7) }.
	expectedSendersChain do: #beLongLived.
	(allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint) beAllocationSite.

	allocationGraph traverseLongLivedSenderChainsUsing: NodeBasedAllocationSiteStrategy new.
	sendersChain := (allocationGraph nodes detect: #isAllocationSite) allocationCallStacks flattened.

	self assert: expectedSendersChain size equals: sendersChain size.
	self assertCollection: expectedSendersChain hasSameElements: sendersChain
]
