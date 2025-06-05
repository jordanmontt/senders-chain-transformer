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
		'allocationGraph'
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

{ #category : 'calculating' }
AllocationSitesExperiment >> identifyAllocationSites [

	allocationGraph identifyAllocationSitesUsing: allocationSiteStrategy
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
	^ aBuilder newList
		items: toPretenureSites keys;
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
   	self identifyAllocationSites.
   	"Get the allocation sites to pretenure"
	toPretenureSites := allocationSiteClassificator longLivedAllocationSites
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
AllocationSitesExperiment >> rewriteToPretenureAllocationSites [

	| allocationSendersList |
	allocationSendersList := toPretenureSites keys collect: [ :allocationGraphEdge | 
		allocationGraphEdge sourceNode allocationPath collect: [ :association |
				MethodWithOffset method: association key method offset: association value ] ].

	pretenurator pretenureAllocations: allocationSendersList
]

{ #category : 'api' }
AllocationSitesExperiment >> run [

	self processAllocationSites.
	self rewriteToPretenureAllocationSites
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
