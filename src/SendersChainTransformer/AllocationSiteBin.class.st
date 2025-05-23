"
I am a simple data structure used by the class IllAnalyzer.
"
Class {
	#name : 'AllocationSiteBin',
	#superclass : 'Object',
	#instVars : [
		'immortalObjects',
		'longLivedObjects',
		'shortLivedObjects',
		'classification',
		'allocationSite'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Classification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Classification'
}

{ #category : 'api' }
AllocationSiteBin >> addImmortalObject: object [

	immortalObjects add: object
]

{ #category : 'api' }
AllocationSiteBin >> addLongLivedObject: object [

	longLivedObjects add: object
]

{ #category : 'api' }
AllocationSiteBin >> addShortLivedObject: object [

	shortLivedObjects add: object
]

{ #category : 'accessing' }
AllocationSiteBin >> allObjects [

	^ self longLivedObjects , self immortalObjects , self shortLivedObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> allocationSite [

	^ allocationSite
]

{ #category : 'accessing' }
AllocationSiteBin >> allocationSite: anAllocationGraphNode [ 
	allocationSite := anAllocationGraphNode
]

{ #category : 'accessing' }
AllocationSiteBin >> classification [

	^ classification
]

{ #category : 'accessing' }
AllocationSiteBin >> classification: obj [

	classification := obj
]

{ #category : 'testing' }
AllocationSiteBin >> containsClass: anObjClass [

	| block |
	block := [ :e | e allocatedObjectClass = anObjClass ].
	^ (longLivedObjects contains: block) or: [
		  (immortalObjects contains: block) or: [
			  shortLivedObjects contains: block ] ]
]

{ #category : 'testing' }
AllocationSiteBin >> hasDoItAllocationSite [

	^ self allObjects anySatisfy: [ :illEphe | illEphe sendersCallStack hasDoItSelector ]
]

{ #category : 'accessing' }
AllocationSiteBin >> immortalObjects [

	^ immortalObjects
]

{ #category : 'initialization' }
AllocationSiteBin >> initialize [

	super initialize.
	immortalObjects := OrderedCollection new.
	longLivedObjects := OrderedCollection new.
	shortLivedObjects := OrderedCollection new
]

{ #category : 'inspector' }
AllocationSiteBin >> inspectorAllocSite [

	<inspectorPresentationOrder: 901 title: 'Allocation site'>
	^ allocationSite inspectorPresenter
]

{ #category : 'testing' }
AllocationSiteBin >> isAmbiguous [

	^ shortLivedObjects notEmpty and: [ longLivedObjects notEmpty or: [ immortalObjects notEmpty ] ]
]

{ #category : 'testing' }
AllocationSiteBin >> isImmortal [

	^ classification = #immortal
]

{ #category : 'testing' }
AllocationSiteBin >> isLong [

	^ classification = #long
]

{ #category : 'testing' }
AllocationSiteBin >> isLongOrImmortal [

	^ self isLong or: [ self isImmortal ]
]

{ #category : 'testing' }
AllocationSiteBin >> isShort [

	^ classification = #short
]

{ #category : 'accessing' }
AllocationSiteBin >> longLivedObjects [

	^ longLivedObjects
]

{ #category : 'printing' }
AllocationSiteBin >> printOn: aStream [

	| text |
	text := classification ifNil: [ '-' ].
	aStream << text << ' bin '
]

{ #category : 'accessing' }
AllocationSiteBin >> shortLivedObjects [

	^ shortLivedObjects
]

{ #category : 'accessing' }
AllocationSiteBin >> totalAllocations [

	^ immortalObjects size + longLivedObjects size + shortLivedObjects size
]
