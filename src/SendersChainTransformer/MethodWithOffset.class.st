Class {
	#name : 'MethodWithOffset',
	#superclass : 'Object',
	#instVars : [
		'method',
		'offset'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'instance creation' }
MethodWithOffset class >> method: aCompiledMethod offset: anInteger [

	^ self new
		  method: aCompiledMethod;
		  offset: anInteger;
		  yourself
]

{ #category : 'accessing' }
MethodWithOffset >> bytecode [

	^ method at: offset
]

{ #category : 'accessing' }
MethodWithOffset >> method [

	^ method
]

{ #category : 'accessing' }
MethodWithOffset >> method: aCompiledMethod [

	method := aCompiledMethod
]

{ #category : 'accessing' }
MethodWithOffset >> offset [

	^ offset
]

{ #category : 'accessing' }
MethodWithOffset >> offset: anInt [

	offset := anInt
]

{ #category : 'accessing' }
MethodWithOffset >> selector [

	^ method selector
]
