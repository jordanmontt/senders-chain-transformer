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
		'toPretenureSites',
		'rawAllocationsSamples',
		'allocationGraph',
		'sendersToPretenure'
	],
	#category : 'SendersChainTransformer-Experiment',
	#package : 'SendersChainTransformer',
	#tag : 'Experiment'
}

{ #category : 'instance creation' }
AllocationSitesExperiment class >> onProfiler: aProfiler [

	^ self new
		  setForProfiler: aProfiler;
		  yourself
]

{ #category : 'accessing' }
AllocationSitesExperiment >> allocationGraph [

	^ allocationGraph
]

{ #category : 'accessing' }
AllocationSitesExperiment >> allocationSiteStrategy [

	^ allocationSiteStrategy
]

{ #category : 'api - accessing' }
AllocationSitesExperiment >> allocationSiteStrategy: aStrategy [

	allocationSiteStrategy := aStrategy
]

{ #category : 'calculating' }
AllocationSitesExperiment >> computeLongLivedAllocationSites [

    allocationSiteClassificator
        setUpForAllocationGraph: allocationGraph;
        computeLongLivedAllocationSites
]

{ #category : 'api' }
AllocationSitesExperiment >> exportAllocationSites: fileName [

    MethodWithOffsetSerializer new
		serialize: sendersToPretenure
		on: fileName asFileReference createFile writeStream
]

{ #category : 'api' }
AllocationSitesExperiment >> getToPretenureAllocationSites [

	sendersToPretenure := OrderedCollection new.
	toPretenureSites do: [ :allocationGraphNode |
			sendersToPretenure addAll:
				(allocationGraphNode allocationPaths collect: [ :aCollection |
						 aCollection collect: [ :edge |
							 MethodWithOffset
								 method: edge sourceNode method
								 offset: edge offset ] ]) ].

	sendersToPretenure := sendersToPretenure select: #isNotEmpty.
	^ sendersToPretenure
]

{ #category : 'initialization' }
AllocationSitesExperiment >> initialize [

	super initialize.

	allocationSiteClassificator := AllocationSiteClassificator new.
	pretenurator := AllocationSitesPretenurer new.
	self useTextualLocationStrategy
]

{ #category : 'inspector' }
AllocationSitesExperiment >> inspector: aBuilder [

	<inspectorPresentationOrder: 0 title: 'To Pretenure Sites'>
	^( aBuilder instantiate: SpListPresenter)
		items: toPretenureSites;
		yourself
]

{ #category : 'api' }
AllocationSitesExperiment >> processAllocationSites [

	"Data cleaning"
	self removeKernelAllocations.
	"Initialize Graph"
	allocationGraph := AllocationGraph onSamples: rawAllocationsSamples.
   	"Get the allocation sites that are classified as long lived using BlackBurn Algorithm"
	self computeLongLivedAllocationSites.
	"Identify allocation sites using strategy"
   allocationGraph identifyAllocationSitesUsing: allocationSiteStrategy.
   	"Get the allocation sites to pretenure"
	^ toPretenureSites := allocationGraph nodes select: #isAllocationSite
]

{ #category : 'removing' }
AllocationSitesExperiment >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{ Context. Deprecation. Process. WeakArray. MouseMoveEvent }
			includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'api' }
AllocationSitesExperiment >> restoreOriginalState [

	pretenurator restoreOriginalState
]

{ #category : 'api' }
AllocationSitesExperiment >> rewriteAllocationSites [

    pretenurator pretenureAllocations: sendersToPretenure.
    ^ pretenurator
]

{ #category : 'api' }
AllocationSitesExperiment >> run [

    self run: (Random new nextInteger: 100000000) asString , '.json'
]

{ #category : 'api' }
AllocationSitesExperiment >> run: aFileName [

    self processAllocationSites.
    self getToPretenureAllocationSites.
    self exportAllocationSites: aFileName
]

{ #category : 'api' }
AllocationSitesExperiment >> sendersToPretenure: anArrayOfArrays [

    sendersToPretenure := anArrayOfArrays
]

{ #category : 'api - accessing' }
AllocationSitesExperiment >> setForProfiler: aProfiler [

	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by time."
	allocationSiteClassificator
		startTime: aProfiler objectAllocations first initializationTime;
		endTime: aProfiler endTime

]

{ #category : 'api - accessing' }
AllocationSitesExperiment >> useTextualLocationStrategy [

	allocationSiteStrategy := TextualLocationOfNewStrategy new
]
