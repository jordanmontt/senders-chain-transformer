Class {
	#name : 'TenuredSelectorMaker',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'defaults' }
TenuredSelectorMaker >> defaultTenuredSelector: aByteSymbol [

	^ #_pretenured_ , aByteSymbol
]

{ #category : 'api' }
TenuredSelectorMaker >> makeSelector: aByteSymbol [

	aByteSymbol = #new ifTrue: [ ^ #newTenured ].
	aByteSymbol = #new: ifTrue: [ ^ #newTenured: ].
	aByteSymbol = #basicNew ifTrue: [ ^ #basicNewTenured ].
	aByteSymbol = #basicNew: ifTrue: [ ^ #basicNewTenured: ].
	^ self defaultTenuredSelector: aByteSymbol
]
