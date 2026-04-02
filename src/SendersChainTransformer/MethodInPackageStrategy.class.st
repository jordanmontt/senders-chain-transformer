Class {
	#name : 'MethodInPackageStrategy',
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
MethodInPackageStrategy class >> applicationPackages: aCol [

    ^ self new
          applicationPackages: aCol;
          yourself
]

{ #category : 'instance creation' }
MethodInPackageStrategy class >> applicationPackagesNames: aCol [

    ^ self new
          applicationPackagesNames: aCol;
          yourself
]

{ #category : 'class initialization' }
MethodInPackageStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #name
]

{ #category : 'accessing' }
MethodInPackageStrategy >> applicationPackages: aCollectionOfPackages [

    self applicationPackagesNames: (aCollectionOfPackages collect: #name)
]

{ #category : 'accessing' }
MethodInPackageStrategy >> applicationPackagesNames: aCollectionOfSymbols [

    applicationPackages := aCollectionOfSymbols
]

{ #category : 'api' }
MethodInPackageStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ self isApplicationMethod: anAllocationGraphNode
]

{ #category : 'api' }
MethodInPackageStrategy >> isApplicationMethod: anAllocationGraphNode [

    ^ applicationPackages includes: anAllocationGraphNode method package name
]
