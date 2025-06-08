"
A TenuredSelectorMakerTest is a test class for testing the behavior of TenuredSelectorMaker
"
Class {
	#name : 'TenuredSelectorMakerTest',
	#superclass : 'TestCase',
	#instVars : [
		'tenuredSelectorMaker'
	],
	#category : 'SendersChainTransformer-Tests-Code-Rewriter',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Code-Rewriter'
}

{ #category : 'running' }
TenuredSelectorMakerTest >> setUp [

	super setUp.

	tenuredSelectorMaker := TenuredSelectorMaker new
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMapBinarySelectorToString [

	| result |
	result := tenuredSelectorMaker mapBinarySelectorToString: '->'.
	self assert: result equals: 'zyIsf'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '==>'.
	self assert: result equals: 'cYzxU'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '+'.
	self assert: result equals: 'vIeqd'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '*'.
	self assert: result equals: 'qemed'.

	result := tenuredSelectorMaker mapBinarySelectorToString: ''.
	self assert: result equals: ''
]
