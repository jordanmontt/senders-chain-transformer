Class {
	#name : 'AllocationSiteIdentificationStrategy',
	#superclass : 'Object',
	#classVars : [
		'KernelPackages'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'class initialization' }
AllocationSiteIdentificationStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #packageName
]

{ #category : 'private' }
AllocationSiteIdentificationStrategy >> edgesHaveSameAllocatedObjectTypes: aListOfEdges [

    | typesInAllocatorEdge |
    aListOfEdges size <= 1 ifTrue: [ ^ true ].

    typesInAllocatorEdge := aListOfEdges first allocatedObjectTypes.
    typesInAllocatorEdge ifEmpty: [ ^ true ].

    ^ aListOfEdges allButFirst allSatisfy: [ :edge |
        | edgeTypes |
        edgeTypes := edge allocatedObjectTypes.
        typesInAllocatorEdge allSatisfy: [ :type | edgeTypes includes: type ] ]
]

{ #category : 'private' }
AllocationSiteIdentificationStrategy >> hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode [

    ^ (anAllocationGraphNode incomingEdges select: #isShortLived) isEmpty
]

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfEdges [
	"It is expected that the allocation paht is set by this method."

	^ self subclassResponsibility
]

{ #category : 'private' }
AllocationSiteIdentificationStrategy >> isKernelMethod: anAllocationGraphNode [

    ^ KernelPackages includes: anAllocationGraphNode method package name
]

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> setUpForGraph: allocationGraph [

    
]
