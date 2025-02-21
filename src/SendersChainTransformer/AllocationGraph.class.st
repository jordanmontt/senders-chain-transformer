Class {
	#name : 'AllocationGraph',
	#superclass : 'Object',
	#instVars : [
		'nodes',
		'samples'
	],
	#category : 'SendersChainTransformer',
	#package : 'SendersChainTransformer'
}

{ #category : 'instance creation' }
AllocationGraph class >> onAllocatedSamples: aCollection [

	^ self new
		  setUpForSamples: aCollection;
		  yourself
]

{ #category : 'as yet unclassified' }
AllocationGraph >> accumulateSample: aSample [

	| callee |
	callee := nil.
	aSample sendersCallStack methodWithOffsetDo: [ :method :offset |
		callee
			ifNil: [ (self nodeFor: method) beLeaf ]
			ifNotNil: [ self recordCallFrom: method to: callee at: offset sample: aSample ].
		method selector = #DoIt ifTrue: [ ^ self ].
		callee := method ]
]

{ #category : 'inspector' }
AllocationGraph >> basicInspect [

	<inspectorPresentationOrder: 0 title: 'Basic info'>
	^ 'Hello' asPresenter
]

{ #category : 'as yet unclassified' }
AllocationGraph >> detectAllocationSitesUsing: aStrategy [

	| workList visitedNodes |
	visitedNodes := Set new.
	workList := OrderedCollection withAll: self leaves.
	[ workList isEmpty ] whileFalse: [
		| current |
		current := workList removeFirst.
		(visitedNodes includes: current) ifFalse: [
			visitedNodes add: current.
			(aStrategy isAllocationSite: current)
				ifTrue: [ current beAllocationSite ]
				ifFalse: [ workList addAll: (current callers reject: [ :caller | visitedNodes includes: caller ]) ] ] ]
]

{ #category : 'initialization' }
AllocationGraph >> initialize [

	super initialize.
	nodes := IdentityDictionary new: 1000
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraph [

	<inspectorPresentationOrder: 2 title: 'Graph'>
	^ AllocationGraphVizu new buildInspectorPresenterFor: self
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraphContext: aContext [

	aContext withoutEvaluator
]

{ #category : 'as yet unclassified' }
AllocationGraph >> leaves [

	^ nodes values select: [ :node | node isLeaf ]
]

{ #category : 'as yet unclassified' }
AllocationGraph >> leavesFor: anEdge [

	anEdge targetNode ifNil: [ ^ { anEdge } ].
	^ anEdge targetNode edges flatCollect: [ :e | self leavesFor: e ]
]

{ #category : 'public' }
AllocationGraph >> nodeFor: aMethod [

	^ nodes at: aMethod ifAbsentPut: [ AllocationGraphNode new method: aMethod ]
]

{ #category : 'accessing' }
AllocationGraph >> nodes [

	^ nodes
]

{ #category : 'as yet unclassified' }
AllocationGraph >> recordCallFrom: aCaller to: aCallee at: anOffset sample: sample [
	"Caller -> the one that calls. Callee -> the one being called"
	| edge callerNode calleeNode |
	callerNode := self nodeFor: aCaller.
	calleeNode := self nodeFor: aCallee.
	edge := callerNode addCallTo: calleeNode withOffset: anOffset.

	calleeNode addCaller: callerNode.

	edge updateFromSample: sample
]

{ #category : 'initialization' }
AllocationGraph >> setUpForSamples: aCollection [

	samples := aCollection.
	aCollection do: [ :sample | self accumulateSample: sample ]
]

{ #category : 'as yet unclassified' }
AllocationGraph >> subGraphForType: aClass [

	^ self class onEphemerons: (samples select: [ :e | e allocatedObjectClass = aClass ])
]
