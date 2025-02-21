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
MethodFromTheSamePackageStrategy class >> packagesToMatch: aCol [

	^ self new
		  packagesToMatch: aCol;
		  yourself
]

{ #category : 'testing' }
MethodFromTheSamePackageStrategy >> isAllocationSite: anAllocationGraphNode [

	^ packagesToMatch includes: anAllocationGraphNode method package
]

{ #category : 'accessing' }
MethodFromTheSamePackageStrategy >> packagesToMatch: aCollectionOfPackages [

	packagesToMatch := aCollectionOfPackages
]

{ #category : 'api' }
MethodFromTheSamePackageStrategy >> removeMisclassifiedSites: aDictionary [

	^ aDictionary select: [ :illAllocationSiteBin |
		  packagesToMatch includes: illAllocationSiteBin allocationSite method package ]
]

{ #category : 'internal' }
MethodFromTheSamePackageStrategy >> stopCriterionForAllocatedClass: allocatedObjectClass receiverPackage: receiverPackage [

	^ packagesToMatch includes: receiverPackage
]
