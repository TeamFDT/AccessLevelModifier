package {
	import fdt.FdtTextEdit;

	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import swf.bridge.FdtEditorContext;
	import swf.bridge.IFdtActionBridge;
	import swf.plugin.ISwfActionPlugin;

	[FdtSwfPlugin(name="AccessLevelModifier", pluginType="action", toolTip="Quickly change visibility of variables and funktions")]
	public class AccessLevelModifier extends Sprite implements ISwfActionPlugin {
		
//		[Embed(source="../assets/VariableIcon.gif", mimeType="application/octet-stream")]
//		public var VariableIcon : Class;
		[Embed(source="../assets/PublicVariableIcon.gif", mimeType="application/octet-stream")]
		private static var PublicVariableIcon : Class;
		[Embed(source="../assets/PrivateVariableIcon.gif", mimeType="application/octet-stream")]
		private var PrivateVariableIcon : Class;
		[Embed(source="../assets/ProtectedVariableIcon.gif", mimeType="application/octet-stream")]
		private var ProtectedVariableIcon : Class;
		[Embed(source="../assets/LocalVariableIcon.gif", mimeType="application/octet-stream")]		
		private var LocalVariableIcon : Class;
		
		private var _FDTBridge : IFdtActionBridge;
		private var firstWord : String;

		public function init(bridge : IFdtActionBridge) : void {
			createLocalReference(bridge);
			registerIcons();
		}

		private function createLocalReference(bridge : IFdtActionBridge) : void {
			_FDTBridge = bridge;
		}

		private function registerIcons() : void {
			_FDTBridge.ui.registerImage("PrivateVariableIcon", new PrivateVariableIcon()).sendTo(this, null);
			_FDTBridge.ui.registerImage("ProtectedVariableIcon", new ProtectedVariableIcon()).sendTo(this, null);
			_FDTBridge.ui.registerImage("LocalVariableIcon", new LocalVariableIcon()).sendTo(this, null);
			_FDTBridge.ui.registerImage("PublicVariableIcon", new PublicVariableIcon()).sendTo(this, null);
		}

		public function createProposals(ec : FdtEditorContext) : void {
			var words : Array = ec.currentLine.replace(/^[\s\t]*/, '').split(" ");
			trace('ec.currentLine: ' + (ec.currentLine));
			var secondWord : String = words [ 1 ];
			var thirdWord : String = words[ 2 ];
			firstWord = words[ 0 ];

			if (secondWord == "var") {
				secondWord = "variable";
			} else if (secondWord == "const") {
				secondWord = "constant";
			} else if (secondWord == "static") {
				if (thirdWord == "var") {
					thirdWord = "variable";
				} else if (thirdWord == "const") {
					thirdWord = "constant";
					secondWord = "static " + thirdWord;
				}
			}

			switch (firstWord) {
				case "public":
					_FDTBridge.offerProposal("private", "PrivateVariableIcon", "Change " + secondWord + " to " + "private", "make private", applyChanges);
					_FDTBridge.offerProposal("internal", "LocalVariableIcon", "Change " + secondWord + " to " + "internal", "make internal", applyChanges);
					_FDTBridge.offerProposal("protected", "ProtectedVariableIcon", "Change " + secondWord + " to " + "protected", "make protected", applyChanges);
					break ;
				case "private":
					_FDTBridge.offerProposal("public", "PublicVariableIcon", "Change " + secondWord + " to " + "public", "make public", applyChanges);
					_FDTBridge.offerProposal("internal", "LocalVariableIcon", "Change " + secondWord + " to " + "internal", "make internal", applyChanges);
					_FDTBridge.offerProposal("protected", "ProtectedVariableIcon", "Change " + secondWord + " to " + "protected", "make protected", applyChanges);
					break ;
				case "internal":
					_FDTBridge.offerProposal("public", "PublicVariableIcon", "Change " + secondWord + " to " + "public", "make public", applyChanges);
					_FDTBridge.offerProposal("private", "PrivateVariableIcon", "Change " + secondWord + " to " + "private", "make private", applyChanges);
					_FDTBridge.offerProposal("protected", "ProtectedVariableIcon", "Change " + secondWord + " to " + "protected", "make protected", applyChanges);
					break ;
				case "protected":
					_FDTBridge.offerProposal("public", "PublicVariableIcon", "Change " + secondWord + " to " + "public", "make public", applyChanges);
					_FDTBridge.offerProposal("private", "PrivateVariableIcon", "Change " + secondWord + " to " + "private", "make private", applyChanges);
					_FDTBridge.offerProposal("internal", "LocalVariableIcon", "Change " + secondWord + " to " + "internal", "make protected", applyChanges);
					break ;
				default:
			}
		}

		public function applyChanges(id : String, ec : FdtEditorContext) : void {
			var textEdits : Vector.<FdtTextEdit> = new Vector.<FdtTextEdit>();
			var currentLineString : String = ec.currentLine.replace(firstWord, id);
			textEdits.push(new FdtTextEdit(ec.currentLineOffset, ec.currentLine.length, currentLineString));
			_FDTBridge.model.fileDocumentModify(ec.currentFile, textEdits).sendTo(this, null);
		}

		public function setOptions(options : Dictionary) : void {
			trace('options: ' + (options));
		}

		public function callEntryAction(entryId : String) : void {
			trace('entryId: ' + (entryId));
		}

		public function dialogClosed(dialogInstanceId : String, result : String) : void {
			trace('result: ' + (result));
			trace('dialogInstanceId: ' + (dialogInstanceId));
		}
	}
}