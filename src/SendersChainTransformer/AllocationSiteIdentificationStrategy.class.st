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
    aListOfEdges ifEmpty: [ ^ true ].

    typesInAllocatorEdge := aListOfEdges first allocatedSamples collect: #allocatedObjectClass as: Set.
    ^ aListOfEdges allButFirst allSatisfy: [ :edge |
        (edge allocatedSamples collect: #allocatedObjectClass as: Set) includesAll: typesInAllocatorEdge ]
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
