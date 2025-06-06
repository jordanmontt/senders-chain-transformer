Class {
	#name : 'MethodFromTheSamePackageStrategy',
	#superclass : 'AllocationSiteIdentificationStrategy',
	#instVars : [
		'packagesToMatch'
	],
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'instance creation' }
MethodFromTheSamePackageStrategy class >> packagesNamesToMatch: aCol [

	| packages |
	packages := aCol collect: #asPackage.
	^ self new
		  packagesToMatch: packages;
		  yourself
]

{ #category : 'instance creation' }
MethodFromTheSamePackageStrategy class >> packagesToMatch: aCol [

	^ self new
		  packagesToMatch: aCol;
		  yourself
]

{ #category : 'api' }
MethodFromTheSamePackageStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

	^ self isMethodInTheSamePackage: anAllocationGraphNode
]

{ #category : 'api' }
MethodFromTheSamePackageStrategy >> isMethodInTheSamePackage: anAllocationGraphNode [

	^ packagesToMatch includes: anAllocationGraphNode method package
]

{ #category : 'accessing' }
MethodFromTheSamePackageStrategy >> packagesToMatch: aCollectionOfPackages [

	packagesToMatch := aCollectionOfPackages
]
