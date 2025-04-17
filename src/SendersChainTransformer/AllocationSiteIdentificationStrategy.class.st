Class {
	#name : 'AllocationSiteIdentificationStrategy',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Allocation-Site-Identification',
	#package : 'SendersChainTransformer',
	#tag : 'Allocation-Site-Identification'
}

{ #category : 'internal' }
AllocationSiteIdentificationStrategy >> allocatorPrimitivesNames [

	self flag: 'This list is harcoded. This needs to be the same as the instrumented primitives in the IllInstrumenter class'.

	^ #( 'Behavior>>#basicNew' 'Behavior>>#basicNew:' 'Behavior>>#basicNewPinned'
	     'Behavior>>#basicNewPinned:' 'Behavior>>#basicNewTenured' 'Behavior>>#basicNewTenured:'
	     'Array class>>#new:' 'Interval class>>#new' 'Number>>#@' 'Object>>#shallowCopy'
	     'Object>>#clone' 'CompiledCode>>#clone' 'ExternalAddress>>#clone' 'FixedBitWidthRegister>>#copy' )
]

{ #category : 'internal' }
AllocationSiteIdentificationStrategy >> identifyAllocationSiteFor: illEphemeron [

	| callStack i sender |
	callStack := illEphemeron sendersCallStack.
	i := 1.
	[ i <= callStack size ] whileTrue: [
		sender := callStack at: i.
		(self stopCriterionForAllocatedClass: illEphemeron allocatedObjectClass receiverPackage: sender method methodClass)
			ifTrue: [	
				illEphemeron
					textualAllocatorMethod: sender method;
					offset: sender offset.
				^ self ].
		i := i + 1 ]
]

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> identifyAllocationSites: objectAllocations [

	objectAllocations do: [ :illEphemeron | self identifyAllocationSiteFor: illEphemeron ].
	^ objectAllocations
]

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> isAllocationSite: anAllocatorNode [

	^ self subclassResponsibility
]

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> removeMisclassifiedSites: aDictionary [

	^ aDictionary reject: [ :illAllocationSiteBin | illAllocationSiteBin allocationSite methodClass = UndefinedObject ]
]

{ #category : 'internal' }
AllocationSiteIdentificationStrategy >> stopCriterionForAllocatedClass: allocatedObjectClass receiverPackage: receiverClass [

	^ self subclassResponsibility
]
