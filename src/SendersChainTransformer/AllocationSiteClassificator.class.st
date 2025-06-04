"
Allocation sites classification algorithm. Paper: https://www.steveblackburn.org/pubs/papers/pbp-toplas-2007.pdf

The algorithm works as follows:

1. Setup. It receives an allocation graph as an input. It takes the nodes of the graph and creates ""allocation bin"" objects, an internal helper data structure, and does some data cleaning.
2. Pruning. It prunes the allocation sites that have total allocation less than 0.000002 times the total allocation.
3. Allocation Site Identification. It traverses the graph and it identifies all the possible allocation sites. It can use different strategies to ask to each node if it is an allocation site.
4. (Optional) Return the allocations that are long or lived
"
Class {
	#name : 'AllocationSiteClassificator',
	#superclass : 'Object',
	#instVars : [
		'maxLiveSize',
		'groupedAllocationSites',
		'startTime',
		'endTime',
		'taThreshold',
		'hif',
		'hlf',
		'immortalObjects',
		'shortObjects',
		'longObjects',
		'allocationGraph'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Classification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Classification'
}

{ #category : 'accessing' }
AllocationSiteClassificator >> allocationGraph: anAllocationGraph [

	allocationGraph := anAllocationGraph
]

{ #category : 'calculating' }
AllocationSiteClassificator >> binObjects [

	groupedAllocationSites keysDo: [ :allocationSiteNode |
		allocationSiteNode allocatedSamples do: [ :illEphe |
			| isObjectClassified |
			isObjectClassified := false.
			(self isObjectImmortal: illEphe) ifTrue: [
					immortalObjects add: illEphe.
					(groupedAllocationSites at: allocationSiteNode) addImmortalObject: illEphe.
					isObjectClassified := true ].
			(isObjectClassified not and: [ self isObjectShortLived: illEphe ]) ifTrue: [
					shortObjects add: illEphe.
					(groupedAllocationSites at: allocationSiteNode) addShortLivedObject: illEphe.
					isObjectClassified := true ].
			isObjectClassified ifFalse: [
					longObjects add: illEphe.
					(groupedAllocationSites at: allocationSiteNode) addLongLivedObject: illEphe ] ] ]
]

{ #category : 'calculating' }
AllocationSiteClassificator >> calculateMaxLiveSize [

	| aliveObjects currentTime  aliveObjectsSize allocatedSamples |
	maxLiveSize := 0.
	allocatedSamples := allocationGraph allocatedSamples sorted: [ :v1 :v2 | v1 initializationTime < v2 initializationTime ].
	aliveObjects := OrderedCollection with: allocatedSamples first.

	allocatedSamples allButFirstDo: [ :illiEphemeron |
		| deadObjects |
		aliveObjectsSize := 0.
		currentTime := illiEphemeron initializationTime - startTime.
		deadObjects := aliveObjects select: [ :e | currentTime >= (e finalizationTime - startTime) ].
		aliveObjects removeAll: deadObjects.
		aliveObjects add: illiEphemeron.
		
		aliveObjects do: [ :e | aliveObjectsSize := aliveObjectsSize + e sizeInBytes ].
		maxLiveSize := maxLiveSize max: aliveObjectsSize ].

	^ maxLiveSize
]

{ #category : 'calculating' }
AllocationSiteClassificator >> classifyAllocationSites [

	groupedAllocationSites valuesDo: [ :allocationSiteBin |
		| is ss ls wasClassified |
		wasClassified := false.
		is := allocationSiteBin immortalObjects sum: #sizeInBytes.
		ss := allocationSiteBin shortLivedObjects sum: #sizeInBytes.
		ls := allocationSiteBin longLivedObjects sum: #sizeInBytes.

		is > (ss + ls + hif) ifTrue: [
			allocationSiteBin classification: #immortal.
			wasClassified := true ].
		(wasClassified not and: [ is + ls > (ss + hlf) ]) ifTrue: [
			allocationSiteBin classification: #long.
			wasClassified := true ].
		wasClassified ifFalse: [ allocationSiteBin classification: #short ] ]
]

{ #category : 'accessing' }
AllocationSiteClassificator >> endTime: anInteger [

	endTime := anInteger
]

{ #category : 'api' }
AllocationSiteClassificator >> getLongLivedAllocationSites [

	self binObjects.
	self pruneAllocationSites.
	self classifyAllocationSites.
	^ groupedAllocationSites select: #isLongOrImmortal
]

{ #category : 'initialization' }
AllocationSiteClassificator >> initialize [

	super initialize.
	immortalObjects := OrderedCollection new: 100000.
	shortObjects := OrderedCollection new: 100000.
	longObjects := OrderedCollection new: 10000.

	taThreshold := 0.45.
	hif := 0.
	hlf := 0.6
]

{ #category : 'calculating' }
AllocationSiteClassificator >> isObjectImmortal: illEphe [

	| timeOfDeath halfwayBirthtimeToEnd birthTime |
	timeOfDeath := illEphe finalizationTime min: endTime.
	birthTime := illEphe initializationTime.
	halfwayBirthtimeToEnd := birthTime + (endTime - illEphe initializationTime / 2).
	^ timeOfDeath > halfwayBirthtimeToEnd

	"^ totalTime - illEphe finalizationTime < illEphe lifetime"
]

{ #category : 'calculating' }
AllocationSiteClassificator >> isObjectShortLived: illEphe [

	| age |
	age := illEphe lifetime / self maxLiveSize.
	^ age < (taThreshold * self maxLiveSize)
]

{ #category : 'accessing' }
AllocationSiteClassificator >> maxLiveSize [

	^ maxLiveSize ifNil: [ self calculateMaxLiveSize ]
]

{ #category : 'calculating' }
AllocationSiteClassificator >> pruneAllocationSites [

	| totalProgramAllocations |
	totalProgramAllocations := allocationGraph allocatedSamples size.
	groupedAllocationSites := groupedAllocationSites reject: [ :allocationSiteBin |
			allocationSiteBin totalAllocations < (self pruningThreshold * totalProgramAllocations) ]
]

{ #category : 'calculating' }
AllocationSiteClassificator >> pruningThreshold [

	^ 0.000002
]

{ #category : 'api' }
AllocationSiteClassificator >> setUpForAllocationGraph: anAllocationGraph [

	allocationGraph := anAllocationGraph.

	groupedAllocationSites := Dictionary new.
	(allocationGraph nodes select: #isAllocationSite) do: [ :allocationSiteNode |
			groupedAllocationSites
				at: allocationSiteNode
				ifAbsentPut: (AllocationSiteBin new
					allocationSite: allocationSiteNode;
					yourself) ]
]

{ #category : 'accessing' }
AllocationSiteClassificator >> shortObjects [

	^ shortObjects
]

{ #category : 'accessing' }
AllocationSiteClassificator >> startTime [

	^ startTime
]

{ #category : 'accessing' }
AllocationSiteClassificator >> startTime: anInteger [

	startTime := anInteger
]

{ #category : 'accessing' }
AllocationSiteClassificator >> totalTime [

	^ endTime - startTime
]
