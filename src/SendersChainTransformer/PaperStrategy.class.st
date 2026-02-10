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

{ #category : 'instance creation' }
PaperStrategy class >> applicationPackagesNames: aCol [

    ^ self new
          applicationPackagesNames: aCol;
          yourself
]

{ #category : 'class initialization' }
PaperStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #name
]

{ #category : 'accessing' }
PaperStrategy >> applicationPackages: aCollectionOfPackages [

    self applicationPackagesNames: (aCollectionOfPackages collect: #name)
]

{ #category : 'accessing' }
PaperStrategy >> applicationPackagesNames: aCollectionOfSymbols [

    applicationPackages := aCollectionOfSymbols
]

{ #category : 'api' }
PaperStrategy >> edgesHaveOnlyOneAllocatedObjectType: aListOfEdges [

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
      & (self edgesHaveOnlyOneAllocatedObjectType: aListOfEdges)
]

{ #category : 'api' }
PaperStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package name
]

{ #category : 'api' }
PaperStrategy >> isKernelMethod: anAllocationGraphNode [

    ^ KernelPackages includes: anAllocationGraphNode method package name
]
