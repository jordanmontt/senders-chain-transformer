Class {
	#name : 'AllocationGraph',
	#superclass : 'Object',
	#instVars : [
		'nodes',
		'samples'
	],
	#category : 'SendersChainTransformer-Allocation-Graph',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Graph'
}

{ #category : 'instance creation' }
AllocationGraph class >> onAllocatedSamples: aCollection [

	^ self new
		  setUpForSamples: aCollection;
		  yourself
]

{ #category : 'private' }
AllocationGraph >> accumulateSample: aSample [

	| callee |
	callee := nil.
	aSample sendersCallStack methodWithOffsetDo: [ :method :offset |
		callee
			ifNil: [ (self nodeFor: method) beLeaf ]
			ifNotNil: [ self recordCallFrom: method  to: callee at: offset sample: aSample ].
		
		method selector = #DoIt ifTrue: [ ^ self ].
		aSample textualAllocatorMethod = method
			ifTrue: [ (self nodeFor: method) beTextualAllocationSite ].
		callee := method ]
]

{ #category : 'accessing' }
AllocationGraph >> allocatedSamples [

	^ nodes values flatCollect: #allocatedSamples as: Set
]

{ #category : 'accessing' }
AllocationGraph >> edgeAtTargetNode: aMethod [

    ^ self edges detect: [ :aGRaphEdge | aGRaphEdge targetNode method = aMethod ]
]

{ #category : 'accessing' }
AllocationGraph >> edges [

	^ nodes values flatCollect: #edges as: Set
]

{ #category : 'api' }
AllocationGraph >> identifyAllocationSitesUsing: aStrategy [

	| workList visitedNodePaths |
	visitedNodePaths := Set new.
	workList := self leaves collect: [ :leafNode | leafNode -> { (leafNode -> nil) } ] as: OrderedCollection.

	[ workList isEmpty ] whileFalse: [
		| current path |
		current := workList first key.
		path := workList first value.
		workList removeFirst.

		(visitedNodePaths includes: current -> path) ifFalse: [
			visitedNodePaths add: current -> path.

			(aStrategy isAllocationSite: current fromAllocationPath: path)
				ifTrue: [ current beAllocationSite ]
				ifFalse: [ 
					workList addAll: (
						current callers collect: [ :caller |
							| offset |
							offset := (caller edgeTo: current) offset.
							path := path copyWith: caller -> offset.
							caller -> path ]) ] ] ]
]

{ #category : 'initialization' }
AllocationGraph >> initialize [

	super initialize.
	nodes := IdentityDictionary new: 1000
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraph: aBuilder [

	<inspectorPresentationOrder: 1 title: 'Graph'>
	^ AllocationGraphVizu new buildInspectorPresenterFor: self
]

{ #category : 'inspector' }
AllocationGraph >> inspectGraphContext: aContext [

	aContext withoutEvaluator
]

{ #category : 'inspector' }
AllocationGraph >> inspectionRaw: aBuilder [
	"Put the raw inspection as ther first tab to avoid freezing the image. The layout of the graph can take time"

	<inspectorPresentationOrder: 0 title: 'Raw'>
	^ aBuilder instantiate: StRawInspectionPresenter on: self
]

{ #category : 'accessing' }
AllocationGraph >> leaves [

	^ nodes values select: [ :node | node isLeaf ]
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

	^ nodes values
]

{ #category : 'accessing' }
AllocationGraph >> nodes: aCollection [

	nodes := aCollection
]

{ #category : 'api' }
AllocationGraph >> pruneGraphFromNewRoot: aCompiledMethod [

	| newRoot newNodes nodesToTreat |
	newRoot := nodes detect: [ :node | node method = aCompiledMethod ].
	nodesToTreat := OrderedCollection with: newRoot.
	newNodes := Set with: newRoot.

	[ nodesToTreat isNotEmpty ] whileTrue: [
		| current |
		current := nodesToTreat removeFirst.
		newNodes addAll: (current edges collect: #targetNode).
		nodesToTreat addAll: (current edges collect: #targetNode) ].

	^ self class new
		  nodes: (newNodes collect: [ :node | node method -> node ]) asDictionary;
		  samples: samples;
		  yourself
]

{ #category : 'private' }
AllocationGraph >> recordCallFrom: aCaller to: aCallee at: anOffset sample: sample [
	"Caller -> the one that calls. Callee -> the one being called"
	| edge callerNode calleeNode |
	callerNode := self nodeFor: aCaller.
	calleeNode := self nodeFor: aCallee.
	edge := callerNode addCallTo: calleeNode withOffset: anOffset.

	calleeNode addCaller: callerNode.

	edge updateFromSample: sample
]

{ #category : 'accessing' }
AllocationGraph >> samples: aCollection [

	samples := aCollection
]

{ #category : 'api' }
AllocationGraph >> setUpForSamples: aCollection [

	samples := aCollection.
	aCollection do: [ :sample | self accumulateSample: sample ]
]

{ #category : 'api' }
AllocationGraph >> subGraphForType: aClass [

	^ self class onAllocatedSamples: (samples select: [ :e | e allocatedObjectClass = aClass ])
]
