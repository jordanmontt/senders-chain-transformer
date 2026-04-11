Class {
	#name : 'PaperStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#instVars : [
		'applicationPackages'
	],
	#classVars : [
		'KernelPackages'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'instance creation' }
PaperStrategy class >> applicationPackages: aCol [

    ^ self new
          applicationPackages: aCol;
          yourself
]

{ #category : 'class initialization' }
PaperStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #packageName
]

{ #category : 'accessing' }
PaperStrategy >> applicationPackages: aCollectionOfPackages [

    applicationPackages := aCollectionOfPackages
]

{ #category : 'api' }
PaperStrategy >> edgesHaveSameAllocatedObjectTypes: aListOfEdges [

    | typesInAllocatorEdge |
    aListOfEdges ifEmpty: [ ^ true ].

    typesInAllocatorEdge := aListOfEdges first allocatedSamples collect: #allocatedObjectClass as: Set.
    ^ aListOfEdges allButFirst allSatisfy: [ :edge |
        (edge allocatedSamples collect: #allocatedObjectClass as: Set) includesAll: typesInAllocatorEdge ]
]

{ #category : 'api' }
PaperStrategy >> hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode [

    ^ (anAllocationGraphNode incomingEdges select: #isShortLived) isEmpty
]

{ #category : 'api' }
PaperStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ (self isApplicationMethod: anAllocationGraphNode)
      & (self hasNotAnyIncomingShortLivedEdges: anAllocationGraphNode)
      & (self edgesHaveSameAllocatedObjectTypes: aListOfEdges)
]

{ #category : 'api' }
PaperStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package
]

{ #category : 'api' }
PaperStrategy >> isKernelMethod: anAllocationGraphNode [

    ^ KernelPackages includes: anAllocationGraphNode method package name
]
