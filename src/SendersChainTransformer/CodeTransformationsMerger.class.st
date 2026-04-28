Class {
	#name : 'CodeTransformationsMerger',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
}

{ #category : 'api' }
CodeTransformationsMerger >> hasDuplicateMethodTransformations: anArrayOfCompiledMethods [

	^ (anArrayOfCompiledMethods collect: #name as: Set) size ~= anArrayOfCompiledMethods size
]

{ #category : 'internals' }
CodeTransformationsMerger >> isTenuredSelector: aSelector [

	^ TenuredSelectorMaker new isTenuredSelector: aSelector
]

{ #category : 'internals' }
CodeTransformationsMerger >> mergeCompiledMethods: compiledMethodsWithTransformations [
	| baseAst baseMessages mergedCompiledMethod |

	baseAst := compiledMethodsWithTransformations first parseTree.
	baseMessages := baseAst allChildren select: #isMessage.

	compiledMethodsWithTransformations allButFirst do: [ :each |
		| sourceMessages |
		sourceMessages := each parseTree allChildren select: #isMessage.
		baseMessages size = sourceMessages size ifFalse: [ self error: 'ASTs are not structurally compatible' ].

		baseMessages
			with: sourceMessages
			do: [ :targetNode :sourceNode |
				(self isTenuredSelector: sourceNode selector)
					ifTrue: [ targetNode selector: (OCSelectorNode value: sourceNode selector) ] ] ].

	mergedCompiledMethod := compiledMethodsWithTransformations first methodClass compiler compile: baseAst formattedCode.

	^ mergedCompiledMethod
]

{ #category : 'api' }
CodeTransformationsMerger >> mergeTransformedCompiledMethods: compiledMethods [

	| repetitions |	
	(self hasDuplicateMethodTransformations: compiledMethods) ifFalse: [ ^ compiledMethods ].
	
	repetitions := Dictionary new.
	compiledMethods do: [ :aCompiledMethod |
		repetitions
			at: aCompiledMethod name
			ifPresent: [ :col | col add: aCompiledMethod ]
			ifAbsentPut: [ OrderedCollection with: aCompiledMethod ] ].

	(repetitions select: [ :col | col size > 1 ]) keysAndValuesDo: [ :methodName :collection |
		| mergedCompiledMethod |
		mergedCompiledMethod := self mergeCompiledMethods: collection.
		repetitions at: methodName put: { mergedCompiledMethod } ].

	^ repetitions values flattened
]
