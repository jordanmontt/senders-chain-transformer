Extension { #name : 'Color' }

{ #category : '*SendersChainTransformer-Tests' }
Color class >> sendersFromHexString: aColorHex [
	"Returns a color instance from HEX (6 element elements)."

	"(Color fromHexString: 'FFFFFF')>>> (Color white) "

	| green red blue alpha hexString |
	hexString := aColorHex withoutPrefix: '#'.
	red := (Integer readFrom: (hexString first: 2) base: 16) / 255.
	green := (Integer readFrom: (hexString copyFrom: 3 to: 4) base: 16) / 255.
	blue := (Integer readFrom: (hexString copyFrom: 5 to: 6) base: 16) / 255.

	alpha := hexString size = 8
		ifFalse: [ 1.0 ]
		ifTrue: [ (Integer readFrom: (hexString copyFrom: 7 to: 8) base: 16) / 255 ].

	^ self r: red g: green b: blue alpha: alpha
]
