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
MethodFromTheSamePackageStrategy >> isAllocationSite: anAllocationGraphNode [

	^ packagesToMatch includes: anAllocationGraphNode method package
]

{ #category : 'accessing' }
MethodFromTheSamePackageStrategy >> packagesToMatch: aCollectionOfPackages [

	packagesToMatch := aCollectionOfPackages
]

{ #category : 'api' }
MethodFromTheSamePackageStrategy >> removeMisclassifiedSites: aDictionary [

	self flag: 'Is this still necessary?'.
	^ aDictionary select: [ :illAllocationSiteBin |
		  packagesToMatch includes: illAllocationSiteBin allocationSite method package ]
]

{ #category : 'internal' }
MethodFromTheSamePackageStrategy >> stopCriterionForAllocatedClass: allocatedObjectClass receiverPackage: receiverPackage [

	^ packagesToMatch includes: receiverPackage
]
