"
A CodeTransformationMergerTest is a test class for testing the behavior of CodeTransformationMerger
"
Class {
	#name : 'CodeTransformationMergerTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformationMerger'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
CodeTransformationMergerTest >> setUp [

	super setUp.

	codeTransformationMerger := CodeTransformationMerger new
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn [

	| modification1 modification2 result originalCompiledMethod expected |
	originalCompiledMethod := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ]';
			compile.
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ]';
			compile.

	result := codeTransformationMerger
			mergeCompiledMethods: { modification2. modification1 }
			into: originalCompiledMethod.
	expected := (OpalCompiler new
			 source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]';
			 compile).
	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn2 [

	| modification1 originalCompiledMethod result |
	originalCompiledMethod :=  OpalCompiler new
			source:'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	result := codeTransformationMerger mergeCompiledMethods: { modification1 } into: originalCompiledMethod.
	self assert: result parseTree equals: modification1 parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn3 [

	| modification2 originalCompiledMethod result |
	originalCompiledMethod :=  OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	result := codeTransformationMerger mergeCompiledMethods: { modification2 } into: originalCompiledMethod.
	self assert: result parseTree equals: modification2 parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn4 [

	| modification3 originalCompiledMethod result |
	originalCompiledMethod := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification3 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	result := codeTransformationMerger mergeCompiledMethods: { modification3 } into: originalCompiledMethod.
	self assert: result parseTree equals: modification3 parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInOtherExample [

	| modification1 modification2 result originalCompiledMethod expected |
	originalCompiledMethod := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	result := codeTransformationMerger mergeCompiledMethods: { modification1. modification2 } into: originalCompiledMethod.
	expected := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	self assert: result parseTree equals: expected parseTree 
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInOtherLongerExample [

	| modification3 modification2 originalCompiledMethod result expected |
	originalCompiledMethod := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification3 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	
	result := codeTransformationMerger mergeCompiledMethods: { modification2. modification3 } into: originalCompiledMethod.
	expected := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	
	self assert: result parseTree equals: result parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInSeveralChanges [

	| originalCompiledMethod modification1 modification2 modification3 result expected |
	originalCompiledMethod := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification3 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	
	result := codeTransformationMerger mergeCompiledMethods: { modification1 . modification2 . modification3 } into: originalCompiledMethod.
	expected := OpalCompiler new
			compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
	compile.
	
	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testNew [

	| transformation1 transformation2 originalMethod transformedMethod expectedMethod |
	codeTransformationMerger := CallSiteTransformer new.

	originalMethod := SCMockClassWithDumbMethods >> #addOccupant:.
	transformation1 := codeTransformationMerger transformMessageSend:
		                   (MethodWithOffset method: SCMockClassWithDumbMethods >> #addOccupant: offset: 81).
	transformation2 := codeTransformationMerger transformMessageSend:
		                   (MethodWithOffset
			                    method: ((SCMockClassWithDumbMethods >> #addOccupant:) literals detect: #isCompiledBlock)
			                    offset: 26).

	transformedMethod := codeTransformationMerger mergeCompiledMethods: { transformation1. transformation2 } into: originalMethod.

	expectedMethod := String streamContents: [ :aStream |
		                  aStream << 'addOccupant: anObject
		(self theOccupants _pretenured_' << codeTransformationMerger selectorMaker randomPrefix asString
		                  << '_at: anObject class name
		ifAbsentPut: [ OrderedCollection newTenured ])
	add: anObject' ].
	expectedMethod := OpalCompiler new source: expectedMethod; compile.

	self assert: expectedMethod parseTree equals: transformedMethod parseTree
]
