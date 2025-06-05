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
MethodFromTheSamePackageStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfNodes [
	"It is expected that the allocation paht is set by this method."

	| isAllocationSite |
	1 halt.
	isAllocationSite := (self isMethodInTheSamePackage: anAllocationGraphNode).
	isAllocationSite ifTrue: [ 1 halt.  anAllocationGraphNode appendPath: aListOfNodes ].
	^ isAllocationSite
]

{ #category : 'api' }
MethodFromTheSamePackageStrategy >> isMethodInTheSamePackage: anAllocationGraphNode [

	^ packagesToMatch includes: anAllocationGraphNode method package
]

{ #category : 'accessing' }
MethodFromTheSamePackageStrategy >> packagesToMatch: aCollectionOfPackages [

	packagesToMatch := aCollectionOfPackages
]
