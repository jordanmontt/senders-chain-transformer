Class {
	#name : 'MethodFromTheSamePackageAllLongLivedStrategy',
	#superclass : 'MethodFromTheSamePackageStrategy',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'api' }
MethodFromTheSamePackageAllLongLivedStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

	^ (aListOfEdges allSatisfy: [ :edge | edge isLongLived ]) and: [
		  self isMethodInTheSamePackage: anAllocationGraphNode ]
]
