"
Allocation sites classification algorithm. Paper: https://www.steveblackburn.org/pubs/papers/pbp-toplas-2007.pdf
"
Class {
	#name : 'AllocationSiteClassificator',
	#superclass : 'Object',
	#instVars : [
		'longObjectsBin',
		'shortObjectsBin',
		'immortalObjectsBin',
		'objectAllocations',
		'maxLiveSize',
		'groupedAllocationSites',
		'startTime',
		'endTime',
		'taThreshold',
		'hif',
		'hlf'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'calculating' }
AllocationSiteClassificator >> binObjects [

	self groupAllocationSites.

	objectAllocations do: [ :illEphe |
		| isObjectClassified |
		isObjectClassified := false.

		(self isObjectImmortal: illEphe) ifTrue: [
			immortalObjectsBin add: illEphe.
			(groupedAllocationSites at: illEphe) addImmortalObject: illEphe.
			isObjectClassified := true ].
		(isObjectClassified not and: [ self isObjectShortLived: illEphe ]) ifTrue: [
			shortObjectsBin add: illEphe.
			(groupedAllocationSites at: illEphe) addShortLivedObject: illEphe.
			isObjectClassified := true ].
		isObjectClassified ifFalse: [
			longObjectsBin add: illEphe.
			(groupedAllocationSites at: illEphe) addLongLivedObject: illEphe ] ]
]

{ #category : 'calculating' }
AllocationSiteClassificator >> calculateMaxLiveSize [

	| aliveObjects currentTime initialTime aliveObjectsSize |
	maxLiveSize := 0.
	initialTime := objectAllocations first initializationTime.
	aliveObjects := OrderedCollection with: objectAllocations first.

	objectAllocations allButFirstDo: [ :illiEphemeron |
		| deadObjects |
		aliveObjectsSize := 0.
		
		currentTime := illiEphemeron initializationTime - initialTime.
		deadObjects := aliveObjects select: [ :e | currentTime >= (e finalizationTime - initialTime) ].
		aliveObjects removeAll: deadObjects.
		aliveObjects add: illiEphemeron.
		
		aliveObjects do: [ :e | aliveObjectsSize := aliveObjectsSize + e sizeInBytes ].
		maxLiveSize := maxLiveSize max: aliveObjectsSize ].

	^ maxLiveSize
]

{ #category : 'api' }
AllocationSiteClassificator >> classifyAllocationSites [

	self binObjects.

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

{ #category : 'calculating' }
AllocationSiteClassificator >> groupAllocationSites [
	
	groupedAllocationSites := Dictionary new.
	objectAllocations do: [ :illEphe |
		| illAllocationSite|
		illAllocationSite := illEphe.
		groupedAllocationSites
			at: illAllocationSite
			ifAbsentPut: (IllAllocationSiteBin new
				allocationSite: illAllocationSite;
				yourself) ]
]

{ #category : 'initialization' }
AllocationSiteClassificator >> initialize [

	super initialize.
	immortalObjectsBin := OrderedCollection new: 100000.
	shortObjectsBin := OrderedCollection new: 100000.
	longObjectsBin := OrderedCollection new: 10000.

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

{ #category : 'accessing' }
AllocationSiteClassificator >> objectAllocations [
	^ objectAllocations
]

{ #category : 'accessing' }
AllocationSiteClassificator >> objectAllocations: aCollection [ 
	objectAllocations := aCollection
]

{ #category : 'api' }
AllocationSiteClassificator >> pruneAllocationSites [

	| v totalProgramAllocations |
	v := 0.000002.
	totalProgramAllocations := objectAllocations size.
	^ groupedAllocationSites reject: [ :allocationSiteBin |
		  allocationSiteBin totalAllocations < (v * totalProgramAllocations) ]
]

{ #category : 'api' }
AllocationSiteClassificator >> retrievePretenureSites [

	self classifyAllocationSites.
	^ self pruneAllocationSites select: #isLongOrImmortal
]

{ #category : 'accessing' }
AllocationSiteClassificator >> shortObjectsBin [

	^ shortObjectsBin
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
