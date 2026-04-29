Class {
	#name : 'SCPathFixture',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'api' }
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

{ #category : 'as yet unclassified' }
SCPathFixture >> dataFramePaths [

	| path1 path2 initialCaller senders senders2  contents copyFromTo next readField readNextRecord readNextRecordAsArray readNextRecordWithoutFieldAccessors readOnlyRowsWith readUnquotedField recordClassNew stringStreamContents |
    contents := SCDataFrameMockClassWithDumbMethods >> #contents.
    copyFromTo := SCDataFrameMockClassWithDumbMethods >> #copyFrom:to:.
    next := SCDataFrameMockClassWithDumbMethods >> #next.
    readField := SCDataFrameMockClassWithDumbMethods >> #readField.
    readNextRecord := SCDataFrameMockClassWithDumbMethods >> #readNextRecord.
    readNextRecordAsArray := SCDataFrameMockClassWithDumbMethods >> #readNextRecordAsArray.
    readNextRecordWithoutFieldAccessors := SCDataFrameMockClassWithDumbMethods >> #readNextRecordWithoutFieldAccessors:.
    readOnlyRowsWith := SCDataFrameMockClassWithDumbMethods >> #readOnlyRowsWith:.
    readUnquotedField := SCDataFrameMockClassWithDumbMethods >> #readUnquotedField.
    recordClassNew := SCDataFrameMockClassWithDumbMethods >> #recordClassNew:.
    stringStreamContents := SCDataFrameMockClassWithDumbMethods >> #stringStreamContents:.

	initialCaller := IllMethodWithOffset method: readOnlyRowsWith offset:  58.
	senders := {
	   IllMethodWithOffset method: recordClassNew offset: 27.
	   IllMethodWithOffset method: readNextRecord offset: 67.
		IllMethodWithOffset method: readNextRecordAsArray offset: 111.         
		IllMethodWithOffset method: next offset: 52 }.
		
	senders2 := {
	   IllMethodWithOffset method: copyFromTo offset: 50.
	   IllMethodWithOffset method: contents offset: 49.
	   IllMethodWithOffset method: stringStreamContents offset: 94.
	   IllMethodWithOffset method: readUnquotedField offset: 94.
	   IllMethodWithOffset method: readField offset: 88.
	   IllMethodWithOffset method: readNextRecordWithoutFieldAccessors offset: 70.
		IllMethodWithOffset method: readNextRecord offset: 75.
		IllMethodWithOffset method: readNextRecordAsArray offset: 111.         
		IllMethodWithOffset method: next offset: 52  }.

	path1 := senders , { initialCaller }.
	path2 := senders2 , { initialCaller }.
	
	^ { path1 . path2 }

]

{ #category : 'as yet unclassified' }
SCPathFixture >> fooPaths [

	| path1 path2 initialCaller senders senders2 |
	initialCaller := IllMethodWithOffset method: (SCMockClassWithDumbMethods >> #tata) offset:  34.
	senders := {
		(IllMethodWithOffset method: SCMockClassWithDumbMethods >> #toto offset: 34) .         
		(IllMethodWithOffset method: SCMockClassWithDumbMethods >> #uaua offset: 42) }.
		
	senders2 := {
		(IllMethodWithOffset method: SCMockClassWithDumbMethods >> #pepe offset: 26) .         
		(IllMethodWithOffset method: SCMockClassWithDumbMethods >> #uaua offset: 45) }.

	path1 := senders , { initialCaller }.
	path2 := senders2 , { initialCaller }.
	
	^ { path1 . path2 }

]
