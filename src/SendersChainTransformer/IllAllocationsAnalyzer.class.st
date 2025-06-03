Class {
	#name : 'IllAllocationsAnalyzer',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'allocationSiteStrategy',
		'allocationSiteClassificator',
		'toPretenureSites',
		'rawAllocationsSamples',
		'allocationGraph'
	],
	#category : 'SendersChainTransformer-Analyzer',
	#package : 'SendersChainTransformer',
	#tag : 'Analyzer'
}

{ #category : 'instance creation' }
IllAllocationsAnalyzer class >> onProfiler: aProfiler [

	^ self new
		  setForProfiler: aProfiler;
		  yourself
]

{ #category : 'accessing' }
IllAllocationsAnalyzer >> allocationSiteStrategy [

	^ allocationSiteStrategy
]

{ #category : 'accessing' }
IllAllocationsAnalyzer >> allocationSiteStrategy: aStrategy [

	allocationSiteStrategy := aStrategy
]

{ #category : 'api' }
IllAllocationsAnalyzer >> analyze [

	self processAllocationSites.
	self rewriteToPretenureAllocationSites
]

{ #category : 'calculating' }
IllAllocationsAnalyzer >> classifyAndPruneToPretenureSites [

	allocationSiteClassificator setUpForAllocationGraph: allocationGraph.
	allocationSiteClassificator classifyAllocationSites.
	^ toPretenureSites := allocationSiteClassificator pruneAllocationSites select: #isLongOrImmortal
]

{ #category : 'calculating' }
IllAllocationsAnalyzer >> identifyAllocationSites [

	allocationGraph := AllocationGraph onAllocatedSamples: rawAllocationsSamples.
	allocationGraph identifyAllocationSitesUsing: allocationSiteStrategy
]

{ #category : 'initialization' }
IllAllocationsAnalyzer >> initialize [

	super initialize.

	allocationSiteClassificator := AllocationSiteClassificator new.
	pretenurator := AllocationSitesPretenurer new.
	self useTextualLocationStrategy
]

{ #category : 'api' }
IllAllocationsAnalyzer >> processAllocationSites [

	self removeKernelAllocations.
	self identifyAllocationSites.

	self classifyAndPruneToPretenureSites.
	self removeMisclassifiedSites
]

{ #category : 'removing' }
IllAllocationsAnalyzer >> removeKernelAllocations [

	rawAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{ Context. Deprecation. Process. WeakArray. MouseMoveEvent }
			includes: illEphemeron allocatedObjectClass ]
]

{ #category : 'calculating' }
IllAllocationsAnalyzer >> removeMisclassifiedSites [

	toPretenureSites := allocationSiteStrategy removeMisclassifiedSites: toPretenureSites.
	^ toPretenureSites
]

{ #category : 'api' }
IllAllocationsAnalyzer >> restoreOriginalState [

	pretenurator restoreOriginalState
]

{ #category : 'api' }
IllAllocationsAnalyzer >> rewriteToPretenureAllocationSites [

	| allocationSendersList |
	allocationSendersList := toPretenureSites values collect: [ :allocSiteBin |
				allocSiteBin allObjects first allocationSenders asMethodWithOffsetObjects ].
	pretenurator pretenureAllocations: allocationSendersList
]

{ #category : 'api - accessing' }
IllAllocationsAnalyzer >> setForProfiler: aProfiler [

	rawAllocationsSamples := aProfiler objectAllocations copy.
	"The ephemerons of the profiler, the allocation samples, are always ordered by time."
	allocationSiteClassificator
		startTime: aProfiler objectAllocations first initializationTime;
		endTime: aProfiler endTime

]

{ #category : 'api - accessing' }
IllAllocationsAnalyzer >> useTextualLocationStrategy [

	allocationSiteStrategy := TextualLocationOfNewStrategy new
]
