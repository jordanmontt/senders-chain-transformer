Class {
	#name : 'DefaultStrategy',
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
DefaultStrategy class >> applicationPackages: aCol [

    ^ self new
          applicationPackages: aCol;
          yourself
]

{ #category : 'instance creation' }
DefaultStrategy class >> applicationPackagesNames: aCol [

    ^ self new
          applicationPackagesNames: aCol;
          yourself
]

{ #category : 'class initialization' }
DefaultStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #name
]

{ #category : 'accessing' }
DefaultStrategy >> applicationPackages: aCollectionOfPackages [

    self applicationPackagesNames: (aCollectionOfPackages collect: #name)
]

{ #category : 'accessing' }
DefaultStrategy >> applicationPackagesNames: aCollectionOfSymbols [

    applicationPackages := aCollectionOfSymbols
]

{ #category : 'api' }
DefaultStrategy >> hasIncomingShortLivedEdges: anAllocationGraphNode [

    ^ (anAllocationGraphNode incomingEdges select: #isShortLived) isNotEmpty
]

{ #category : 'api' }
DefaultStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ self isApplicationMethod: anAllocationGraphNode
]

{ #category : 'api' }
DefaultStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package name
]

{ #category : 'api' }
DefaultStrategy >> isKernelMethod: anAllocationGraphNode [

    ^ KernelPackages includes: anAllocationGraphNode method package name
]
