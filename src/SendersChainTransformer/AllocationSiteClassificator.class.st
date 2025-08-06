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

	groupedAllocationSites keysDo: [ :allocationGraphComponent |
		allocationGraphComponent allocatedSamples do: [ :illEphe |
			| isObjectClassified |
			isObjectClassified := false.
			(self isObjectImmortal: illEphe) ifTrue: [
					(groupedAllocationSites at: allocationGraphComponent) addImmortalObject: illEphe.
					isObjectClassified := true ].
			(isObjectClassified not and: [ self isObjectShortLived: illEphe ]) ifTrue: [
					(groupedAllocationSites at: allocationGraphComponent) addShortLivedObject: illEphe.
					isObjectClassified := true ].
			isObjectClassified ifFalse: [
					(groupedAllocationSites at: allocationGraphComponent) addLongLivedObject: illEphe ] ] ]
]

{ #category : 'calculating' }
AllocationSiteClassificator >> calculateMaxLiveSize [

    | currentTime aliveObjectsSize allocatedSamples deathObjects |
    maxLiveSize := 0.
    allocatedSamples := allocationGraph allocatedSamples sorted: [ :v1 :v2 |
				v1 initializationTime < v2 initializationTime ].
    deathObjects := (allocationGraph allocatedSamples sorted: [ :v1 :v2 |
				v1 finalizationTime < v2 finalizationTime ]) readStream.

    aliveObjectsSize := 0.
    allocatedSamples do: [ :illiEphemeron |
		currentTime := illiEphemeron initializationTime.
		
		[ deathObjects peek finalizationTime <= currentTime ] whileTrue: [
				| theDeadObject |
				theDeadObject := deathObjects next.
				aliveObjectsSize := aliveObjectsSize - theDeadObject sizeInBytes ].

		aliveObjectsSize := aliveObjectsSize + illiEphemeron sizeInBytes.
		maxLiveSize := maxLiveSize max: aliveObjectsSize ].

    ^ maxLiveSize
]

{ #category : 'calculating' }
AllocationSiteClassificator >> classifyAllocationSites [

	groupedAllocationSites keysAndValuesDo: [ :allocationGraphComponent :allocationSiteBin |
		| is ss ls wasClassified |
		wasClassified := false.
		is := allocationSiteBin immortalObjects sum: #sizeInBytes.
		ss := allocationSiteBin shortLivedObjects sum: #sizeInBytes.
		ls := allocationSiteBin longLivedObjects sum: #sizeInBytes.

		is > (ss + ls + hif) ifTrue: [
			allocationSiteBin classification: #immortal.
			allocationGraphComponent beImmortal.
			wasClassified := true ].
		(wasClassified not and: [ is + ls > (ss + hlf) ]) ifTrue: [
			allocationSiteBin classification: #long.
			allocationGraphComponent beLongLived.
			wasClassified := true ].
		wasClassified ifFalse: [
			allocationSiteBin classification: #short.
			allocationGraphComponent beShortLived ] ]
]

{ #category : 'api' }
AllocationSiteClassificator >> computeLongLivedAllocationSites [

	self binObjects.
	self pruneAllocationSites.
	self classifyAllocationSites
]

{ #category : 'accessing' }
AllocationSiteClassificator >> endTime: anInteger [

	endTime := anInteger
]

{ #category : 'accessing' }
AllocationSiteClassificator >> groupedAllocationSites [
	^ groupedAllocationSites
]

{ #category : 'initialization' }
AllocationSiteClassificator >> initialize [

	super initialize.

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
]

{ #category : 'calculating' }
AllocationSiteClassificator >> isObjectShortLived: illEphe [

	| age |
	age := illEphe lifetime / self maxLiveSize.
	^ age < (taThreshold * self maxLiveSize)
]

{ #category : 'api' }
AllocationSiteClassificator >> longLivedAllocationSites [

    ^ groupedAllocationSites select: #isLongOrImmortal
]

{ #category : 'accessing' }
AllocationSiteClassificator >> maxLiveSize [

	^ maxLiveSize ifNil: [ self calculateMaxLiveSize ]
]

{ #category : 'calculating' }
AllocationSiteClassificator >> pruneAllocationSites [

	| totalProgramAllocations sitesWithSignificantSize |
	totalProgramAllocations := allocationGraph allocatedSamples size.
	sitesWithSignificantSize := groupedAllocationSites associations reject: [ :assoc |
			assoc key allocatedSamples size < (self pruningThreshold * totalProgramAllocations) ].
	groupedAllocationSites := Dictionary newFrom: sitesWithSignificantSize
]

{ #category : 'calculating' }
AllocationSiteClassificator >> pruningThreshold [

	^ 0.000002
]

{ #category : 'api' }
AllocationSiteClassificator >> setUpForAllocationGraph: anAllocationGraph [

	allocationGraph := anAllocationGraph.

	groupedAllocationSites := Dictionary new.
	allocationGraph edges do: [ :allocationGraphNode |
			groupedAllocationSites
				at: allocationGraphNode
				ifAbsentPut: (AllocationSiteBin new
					allocationSite: allocationGraphNode;
					yourself) ]
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
