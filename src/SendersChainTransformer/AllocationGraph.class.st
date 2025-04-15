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

{ #category : 'computing' }
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

{ #category : 'api' }
AllocationGraph >> buildSubgraphFromMethod: aCompiledMethod [

	| newRoot newNodes nodesToTreat |
	newRoot := nodes detect: [ :node | node method = aCompiledMethod ].
	nodesToTreat := OrderedCollection with: newRoot.
	newNodes := Set with: newRoot.

	[ nodesToTreat isNotEmpty ] whileTrue: [
		| current |
		current := nodesToTreat removeFirst.
		newNodes addAll: (current edges values collect: #targetNode).
		nodesToTreat addAll: (current edges values collect: #targetNode) ].

	^ self class new
		  nodes: (newNodes collect: [ :node | node method -> (self nodeFor: node method) ]) asDictionary;
		  yourself
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

	<inspectorPresentationOrder: 1 title: 'Graph'>
	^ AllocationGraphVizu new buildInspectorPresenterFor: self
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraphContext: aContext [

	aContext withoutEvaluator
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraphTreeLayout [

	<inspectorPresentationOrder: 2 title: 'Graph Tree'>
	^ AllocationGraphVizu new
		  withTreeLayout;
		  buildInspectorPresenterFor: self
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraphTreeLayoutContext: aContext [

	aContext withoutEvaluator
]

{ #category : 'inspector' }
AllocationGraph >> inspectionRaw [
	"Put the raw inspection as ther first tab to avoid freezing the image. The layout of the graph can take time"
	<inspectorPresentationOrder: 0 title: 'Raw'>
	^ StRawInspectionPresenter on: self
]

{ #category : 'accessing' }
AllocationGraph >> leaves [

	^ nodes values select: [ :node | node isLeaf ]
]

{ #category : 'as yet unclassified' }
AllocationGraph >> leavesFor: anEdge [

	anEdge targetNode ifNil: [ ^ { anEdge } ].
	^ anEdge targetNode edges flatCollect: [ :e | self leavesFor: e ]
]

{ #category : 'accessing' }
AllocationGraph >> nodeAt: aMethod [
	"Using the name because of the allocation primitives. When they were captured, the source code contained the 'trapMethod' code. After, if we want to access it later, the trapMethod code has been discared and the normal code it was put back. Because of this we need to use the name else we will get the a key not found error"
	^ nodes at: aMethod ifAbsent: [ self leaves detect: [ :leaf | leaf method name = aMethod name ] ]
]

{ #category : 'private' }
AllocationGraph >> nodeFor: aMethod [

	^ nodes at: aMethod ifAbsentPut: [ AllocationGraphNode new method: aMethod ]
]

{ #category : 'accessing' }
AllocationGraph >> nodes [

	^ nodes
]

{ #category : 'accessing' }
AllocationGraph >> nodes: aCollection [

	nodes := aCollection
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

{ #category : 'api' }
AllocationGraph >> setUpForSamples: aCollection [

	samples := aCollection.
	aCollection do: [ :sample | self accumulateSample: sample ]
]

{ #category : 'as yet unclassified' }
AllocationGraph >> subGraphForType: aClass [

	^ self class onEphemerons: (samples select: [ :e | e allocatedObjectClass = aClass ])
]
