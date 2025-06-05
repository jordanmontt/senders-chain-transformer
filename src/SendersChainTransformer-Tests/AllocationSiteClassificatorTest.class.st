"
An IllAnalyzerTest is a test class for testing the behavior of IllAnalyzer
"
Class {
	#name : 'AllocationSiteClassificatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'classificator',
		'profiler',
		'allocationGraph'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
AllocationSiteClassificatorTest >> setUp [

	super setUp.

	classificator := AllocationSiteClassificator new
]

{ #category : 'tests' }
AllocationSiteClassificatorTest >> setUpAllocationGraph [
	
	| samples |
	profiler := IllMemoryProfiler new
			samplingRate: 1;
			profileOn: [ AllocationGraphFixture entryPoint ];
			yourself.

	samples := profiler objectAllocations select: [ :ephemeron |
			{ Array. Behavior } includes: ephemeron allocatedObjectClass ].

	allocationGraph := AllocationGraph onSamples: samples.
	allocationGraph := allocationGraph pruneFromRoot: (allocationGraph nodeAtMethod: AllocationGraphFixture class >> #entryPoint).
	allocationGraph identifyAllocationSitesUsing: TextualLocationOfNewStrategy new.
]

{ #category : 'tests' }
AllocationSiteClassificatorTest >> testBinObjects [

    | binnedAllocationSites |
    self setUpAllocationGraph.

    classificator
        startTime: profiler objectAllocations first initializationTime;
        endTime: profiler endTime;
        setUpForAllocationGraph: allocationGraph.
    classificator binObjects.

    binnedAllocationSites := classificator groupedAllocationSites values.

    self
		assert: ( binnedAllocationSites detect: [ :bin |
    			bin allocationSite method = (AllocationGraphFixture class >> #m1) ] )
                immortalObjects size
    	equals: 25.
	 self
		assert: ( binnedAllocationSites detect: [ :bin |
    			bin allocationSite method = (AllocationGraphFixture class >> #m3) ] )
                immortalObjects size
    	equals: 20.
     self
		assert: ( binnedAllocationSites detect: [ :bin |
    			bin allocationSite method = (AllocationGraphFixture class >> #m4) ] )
                immortalObjects size
    	equals: 5.
     self
		assert: ( binnedAllocationSites detect: [ :bin |
    			bin allocationSite method = (AllocationGraphFixture class >> #m5) ] )
                immortalObjects size
    	equals: 5.
     self
		assert: ( binnedAllocationSites detect: [ :bin |
    			bin allocationSite method = (AllocationGraphFixtureUtilities class >> #mm)] )
                immortalObjects size
    	equals: 5
]

{ #category : 'tests' }
AllocationSiteClassificatorTest >> testCalculateMaxLiveSize [

	| mockedAllocationGraph |
	mockedAllocationGraph := MockedClassForMaxSizeTest new.
	
	classificator
		allocationGraph: mockedAllocationGraph;
		startTime: mockedAllocationGraph initialTime;
		endTime: mockedAllocationGraph endTime.

	self assert: classificator maxLiveSize equals: 140 "j and m are the only alive objects at point 13 of the timeline. J weights 100 bytes and m 40".
]

{ #category : 'tests' }
AllocationSiteClassificatorTest >> testIsObjectImmortal [

	| startTime endTime illEphe |
	startTime := 10.
	endTime := 110.
	
	classificator
		endTime: endTime;
		startTime: startTime.

	illEphe := IllEphemeron new
		initializationTime: 30;
		finalizationTime: 70;
		yourself.
	self deny: (classificator isObjectImmortal: illEphe).
	
	illEphe := IllEphemeron new
		initializationTime: 30;
		finalizationTime: 71;
		yourself.
	self assert: (classificator isObjectImmortal: illEphe).
	
	illEphe := IllEphemeron new
		initializationTime: 10;
		finalizationTime: 110;
		yourself.
	self assert: (classificator isObjectImmortal: illEphe).
	
	"Strange case"
	classificator := AllocationSiteClassificator new
		startTime: 0;
		endTime: 17;
		yourself.
	illEphe := IllEphemeron new
		initializationTime: 10;
		finalizationTime: 11;
		yourself.
	self deny: (classificator isObjectImmortal: illEphe).
]
