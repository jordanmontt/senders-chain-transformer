Extension { #name : 'BytecodeEncoder' }

{ #category : '*SendersChainTransformer' }
BytecodeEncoder class >> specialSelectors [
	^ #(#+ #- #< #> #'<=' #'>=' #= #'~=' #* #/ #'\\' #@ #bitShift: #'//' #bitAnd: #bitOr: #at: #at:put: #size #'==' nil "class" #'~~' #value #value: #x #y)
]
