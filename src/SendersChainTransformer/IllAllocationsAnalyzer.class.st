Class {
	#name : 'IllAllocationsAnalyzer',
	#superclass : 'Object',
	#instVars : [
		'pretenurator',
		'allocationSiteStrategy',
		'allocationSiteClassificator',
		'toPretenureSites',
		'rawObjectAllocationsSamples'
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

{ #category : 'calculating' }
IllAllocationsAnalyzer >> classifyAllocationSites [

	toPretenureSites := allocationSiteClassificator retrievePretenureSites.
	^ toPretenureSites
]

{ #category : 'calculating' }
IllAllocationsAnalyzer >> identifyAllocationSites [

	allocationSiteStrategy identifyAllocationSites: rawObjectAllocationsSamples.
]

{ #category : 'initialization' }
IllAllocationsAnalyzer >> initialize [

	super initialize.

	allocationSiteClassificator := AllocationSiteClassificator new.
	pretenurator := AllocationSitesPretenurer new.
	self useTextualLocationStrategy
]

{ #category : 'calculating' }
IllAllocationsAnalyzer >> pretenureAllocationSites [

	| allocationSendersList |
	allocationSendersList := toPretenureSites values collect: [ :allocSiteBin |
				allocSiteBin allObjects first allocationSenders asMethodWithOffsetObjects ].
	pretenurator pretenureAllocations: allocationSendersList
]

{ #category : 'api' }
IllAllocationsAnalyzer >> processAndPretenureAllocationSites [

	| allocationGraph detectedAllocSites |
	self removeKernelAllocations.

	allocationGraph := AllocationGraph onAllocatedSamples: rawObjectAllocationsSamples.
	allocationGraph detectAllocationSitesUsing: (MethodFromTheSamePackageStrategy packagesToMatch: AlSitExCormas applicationPackages).
	
	1 halt.

	rawObjectAllocationsSamples := (allocationGraph nodes select: #isAllocationSite)
		flatCollect: [ :node | node edges values
			collect: [ : edge | MethodWithOffset method: node method offset: edge offset  ]  ].

	"self identifyAllocationSites."
	self classifyAllocationSites.
	self removeMisclassifiedSites.	

	self pretenureAllocationSites
]

{ #category : 'removing' }
IllAllocationsAnalyzer >> removeKernelAllocations [

	rawObjectAllocationsSamples removeAllSuchThat: [ :illEphemeron |
		{
			Context.
			Deprecation.
			Process.
			WeakArray.
			MouseMoveEvent } includes: illEphemeron allocatedObjectClass ]
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

{ #category : 'initialization' }
IllAllocationsAnalyzer >> setForProfiler: aProfiler [

	rawObjectAllocationsSamples := aProfiler objectAllocations copy.
	allocationSiteClassificator
		objectAllocations: rawObjectAllocationsSamples;
		endTime: aProfiler endTime;
		startTime: aProfiler startTime
]

{ #category : 'api' }
IllAllocationsAnalyzer >> useTextualLocationStrategy [

	allocationSiteStrategy := TextualLocationOfNewStrategy new
]
