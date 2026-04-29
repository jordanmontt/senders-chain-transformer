Class {
	#name : 'SCDataFrameMockClassWithDumbMethods',
	#superclass : 'Object',
	#instVars : [
		'rows',
		'recordClass',
		'fieldCount',
		'fieldAccessors',
		'recordClassIsIndexable',
		'emptyFieldValue',
		'emptyFieldInput',
		'stringStream',
		'readLimit',
		'collection'
	],
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> contents [

	| position |
	readLimit := readLimit max: position.
	^ collection copyFrom: 1 to: position
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> copyFrom: start to: stop [
	"Answer a copy of a subset of the receiver, starting from element at
	index start until element at index stop."

	| newSize |
	newSize := stop - start + 1.
	^ (self species new: newSize)
		  replaceFrom: 1
		  to: newSize
		  with: self
		  startingAt: start
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> next [
	"Read the next record.
	I will return an instance of recordClass."

	^ recordClassIsIndexable
		  ifTrue: [ self readNextRecordAsArray ]
		  ifFalse: [ self readNextRecordAsObject ]
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> readField [

	| field |
	field := self peekQuote
		         ifTrue: [ self readQuotedField ]
		         ifFalse: [ self readUnquotedField ].
	(field ~= emptyFieldValue and: [ emptyFieldInput notNil ]) ifTrue: [
		(emptyFieldInput value: field) ifTrue: [ ^ emptyFieldValue ] ].
	^ field
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> readNextRecord [

	| record |
	record := self recordClassNew: fieldCount.
	fieldAccessors
		ifNil: [ self readNextRecordWithoutFieldAccessors: record ]
		ifNotNil: [ self readNextRecordWithFieldAccessors: record ].
	self handleEndOfRecord.
	^ record
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> readNextRecordAsArray [

	fieldAccessors ifNotNil: [
		self fieldCount: (fieldAccessors count: [ :each | each notNil ]) ].
	^ fieldCount
		  ifNil: [
				  | record |
				  record := self readFirstRecord.
				  self fieldCount: record size.
				  record ]
		  ifNotNil: [ self readNextRecord ]
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> readNextRecordWithoutFieldAccessors: record [

	1 to: fieldCount do: [ :each |
			record at: each put: self readField.
			each = fieldCount ifFalse: [ self handleSeparator ] ]
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> readOnlyRowsWith: aReader [

	rows := OrderedCollection new.

	[ aReader atEnd ] whileFalse: [
		rows add: aReader next ]
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> readUnquotedField [

	(self atEnd or: [ self peekSeparator or: [ self peekEndOfLine ] ])
		ifTrue: [ ^ emptyFieldValue ].
	^ self stringStreamContents: [ :stream |
			  [
			  self atEnd or: [ self peekSeparator or: [ self peekEndOfLine ] ] ]
				  whileFalse: [ stream nextPut: self nextChar ] ]
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> recordClassNew: size [

	^ recordClass new: size
]

{ #category : 'reading' }
SCDataFrameMockClassWithDumbMethods >> stringStreamContents: block [
	"Like String streamContents: block
	but reusing the underlying buffer for improved efficiency"

	stringStream ifNil: [ stringStream := (String new: 32) writeStream ].
	stringStream reset.
	block value: stringStream.
	^ stringStream contents
]
