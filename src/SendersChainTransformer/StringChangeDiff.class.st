Class {
	#name : 'StringChangeDiff',
	#superclass : 'Object',
	#instVars : [
		'start',
		'length',
		'change'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'instance creation' }
StringChangeDiff class >> start: anInteger length: anInteger2 change: aString [

	^ self new
		  start: anInteger;
		  length: anInteger2;
		  change: aString;
		  yourself
]

{ #category : 'accessing' }
StringChangeDiff >> change [
	^ change
]

{ #category : 'accessing' }
StringChangeDiff >> change: aString [ 
	change := aString
]

{ #category : 'accessing' }
StringChangeDiff >> length [
	^ length
]

{ #category : 'accessing' }
StringChangeDiff >> length: anInteger [ 
	length := anInteger
]

{ #category : 'accessing' }
StringChangeDiff >> start [
	^ start
]

{ #category : 'accessing' }
StringChangeDiff >> start: anInteger [ 
	start := anInteger
]
