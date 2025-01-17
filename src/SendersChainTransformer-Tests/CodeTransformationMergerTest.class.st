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

	| modification1 modification2 result originalString |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ]'.
	modification1 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]'.
	modification2 := 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification2 . modification1 } in: originalString.
	self assert: result equals: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]'
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn2 [

	| modification1 originalString result |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification1 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification1 } in: originalString.
	self assert: result equals: modification1
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn3 [

	| modification2 originalString result |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification2 := 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification2 } in: originalString.
	self assert: result equals: modification2
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn4 [

	| modification3 originalString result |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification3 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification3 } in: originalString.
	self assert: result equals: modification3
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInOtherExample [

	| modification1 modification2 result originalString |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification1 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification2 := 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification1. modification2 } in: originalString.
	self assert: result equals: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInOtherLongerExample [

	| modification3 modification2 originalString result |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification2 := 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification3 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification2. modification3 } in: originalString.
	self assert: result equals: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInSeveralChanges [

	| originalString modification1 modification2 modification3 result |
	originalString :=  'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification1 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification2 := 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification3 := 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.
	result := codeTransformationMerger mergeCodeTransformations: { modification1 . modification2 . modification3 } in: originalString.
	self assert: result equals: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'
]
