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

{ #category : 'api' }
AllocationSiteIdentificationStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfNodes [
	"It is expected that the allocation paht is set by this method."

	^ self subclassResponsibility
]
