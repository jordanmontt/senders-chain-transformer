Class {
	#name : 'SCPathFixture',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'as yet unclassified' }
SCPathFixture >> cormasExpectedTransformations [

	| initialCaller senders initialCaller2 path1 path2 |
	initialCaller := IllMethodWithOffset method: (SCMockClassWithDumbMethods >> #addOccupant:) offset:  81.
	senders := {
		           (IllMethodWithOffset method: SCMockAssociation class >> #key:value: offset: 42).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82).
		           (IllMethodWithOffset method: (SCMockDictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsent: offset: 54).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsentPut: offset: 48) }.

	initialCaller2 := IllMethodWithOffset
		             method: (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock
		             offset: 26.

	path1 := senders , { initialCaller }.
	path2 := { } , { initialCaller2 }.
   ^ { path1 . path2 }
]

{ #category : 'as yet unclassified' }
SCPathFixture >> cormasPaths [

	| initialCaller senders initialCaller2 path1 path2 |
	initialCaller := IllMethodWithOffset method: (SCMockClassWithDumbMethods >> #addOccupant:) offset:  81.
	senders := {
		           (IllMethodWithOffset method: SCMockAssociation class >> #key:value: offset: 42).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82).
		           (IllMethodWithOffset method: (SCMockDictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsent: offset: 54).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsentPut: offset: 48) }.

	initialCaller2 := IllMethodWithOffset
		             method: (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock
		             offset: 26.

	path1 := senders , { initialCaller }.
	path2 := { } , { initialCaller2 }.
   ^ { path1. path2 }
]
