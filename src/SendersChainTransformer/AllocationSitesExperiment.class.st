"
The algorithm works as follow:

1. Data cleaning. Clean noise if any.
2. Allocation graph. Create an allocation graph using the samples as an input. The samples are objects obtained during profiling that contain information about the stack, the object lifetime, etc.
3. Identify the allocation sites using different strategies. Mark the nodes in the graph.
4. Classify the allocation sites as long or short using Blackburn's algorithm.
5. Rewrite the code from the allocation site to the primitive allocator creating an unique path. 
 
"
Class {
	#name : 'AllocationSitesExperiment',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'allocationSiteStrategy',
		'allocationSiteClassificator',
		'rawAllocationsSamples',
		'allocationGraph',
		'sendersToPretenure'
	],
	#category : 'SendersChainTransformer-Experiment',
	#package : 'SendersChainTransformer',
	#tag : 'Experiment'
}

{ #category : 'instance creation' }
AllocationSitesExperiment class >> onProfiler: aProfiler traversalStrategy: aStrategy [

    ^ self new
          setUpForProfiler: aProfiler;
          allocationSiteStrategy: aStrategy;
          yourself
]

{ #category : 'api - accessing' }
AllocationSitesExperiment >> allocationSiteStrategy: aStrategy [

	allocationSiteStrategy := aStrategy
]

{ #category : 'calculating' }
AllocationSitesExperiment >> classifyEdgesByLifetime [

    allocationSiteClassificator
        setUpForAllocationGraph: allocationGraph;
        classifyEdgesByLifetime
]

{ #category : 'api' }
AllocationSitesExperiment >> constructAllocationGraph [

    self removeKernelAllocations.
    allocationGraph := AllocationGraph onSamples: rawAllocationsSamples
]

{ #category : 'api - exporting' }
AllocationSitesExperiment >> exportAllocationSites [

    self exportAllocationSites: (Random new nextInteger: 100000000) asString , '.json'
]

{ #category : 'api - exporting' }
AllocationSitesExperiment >> exportAllocationSites: fileName [

    MethodWithOffsetSerializer new
		serialize: sendersToPretenure
		on: fileName asFileReference createFile writeStream
]

{ #category : 'api' }
AllocationSitesExperiment >> extractLongLivedSendersChains [

    sendersToPretenure := allocationSiteStrategy extractLongLivedSendersChains: allocationGraph.
    ^ sendersToPretenure
]

{ #category : 'initialization' }
AllocationSitesExperiment >> initialize [

    super initialize.

    allocationSiteClassificator := PretenuringAdviceAlgorithm new.
    pretenurator := AllocationSitesPretenurer new.
    sendersToPretenure := OrderedCollection new
]

{ #category : 'inspector' }
AllocationSitesExperiment >> inspector: aBuilder [

    <inspectorPresentationOrder: 1 title: 'To Pretenure Sites'>
    ^ sendersToPretenure inspectionItems: aBuilder
]

{ #category : 'calculating' }
AllocationSitesExperiment >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{ Context. Deprecation. Process. WeakArray. MouseMoveEvent }
			includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'api' }
AllocationSitesExperiment >> restoreSourceCodeToOriginalState [

	pretenurator restoreOriginalState
]

{ #category : 'api' }
AllocationSitesExperiment >> rewriteAllocationSites [

    pretenurator pretenureAllocations: sendersToPretenure.
    ^ pretenurator
]

{ #category : 'api' }
AllocationSitesExperiment >> run [

   self constructAllocationGraph.

   	self classifyEdgesByLifetime.

	allocationSiteStrategy setUpForGraph: allocationGraph.
	allocationGraph traverseLongLivedSenderChainsUsing: allocationSiteStrategy.
   self extractLongLivedSendersChains.

	"self rewriteAllocationSites"
]

{ #category : 'api - accessing' }
AllocationSitesExperiment >> sendersToPretenure: anArrayOfArrays [

    sendersToPretenure := anArrayOfArrays
]

{ #category : 'api - accessing' }
AllocationSitesExperiment >> setUpForProfiler: aProfiler [

	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by time."
	allocationSiteClassificator
		startTime: aProfiler objectAllocations first initializationTime;
		endTime: aProfiler endTime

]
