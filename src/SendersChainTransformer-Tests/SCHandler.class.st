Class {
	#name : 'SCHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'calledMethods'
	],
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'evaluating' }
SCHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: returnValue [

	| filteredContext |
	filteredContext := thisContext sender. "this is the MethodProxies Handler"
	calledMethods add: filteredContext selector.
	^ returnValue
]

{ #category : 'accessing' }
SCHandler >> calledMethods [

	^ calledMethods
]

{ #category : 'initialization' }
SCHandler >> initialize [

	super initialize.
	calledMethods := OrderedCollection new
]
