import "../template_ast.dart"
    show
        TemplateAst,
        TemplateAstVisitor,
        NgContentAst,
        EmbeddedTemplateAst,
        ElementAst,
        ReferenceAst,
        VariableAst,
        BoundEventAst,
        BoundElementPropertyAst,
        AttrAst,
        BoundTextAst,
        TextAst,
        DirectiveAst,
        BoundDirectivePropertyAst,
        templateVisitAll;
import "compile_element.dart" show CompileElement;
import "compile_view.dart" show CompileView;
import "event_binder.dart"
    show
        bindRenderOutputs,
        collectEventListeners,
        CompileEventListener,
        bindDirectiveOutputs;
import "lifecycle_binder.dart"
    show
        bindDirectiveAfterContentLifecycleCallbacks,
        bindDirectiveAfterViewLifecycleCallbacks,
        bindDirectiveDestroyLifecycleCallbacks,
        bindPipeDestroyLifecycleCallbacks,
        bindDirectiveDetectChangesLifecycleCallbacks;
import "property_binder.dart"
    show
        bindRenderText,
        bindRenderInputs,
        bindDirectiveInputs,
        bindDirectiveHostProps;

/// Visits view nodes to generate code for bindings.
///
/// Called by ViewCompiler for each top level CompileView and the
/// ViewBinderVisitor recursively for each embedded template.
void bindView(CompileView view, List<TemplateAst> parsedTemplate) {
  var visitor = new ViewBinderVisitor(view);
  templateVisitAll(visitor, parsedTemplate);
  view.pipes.forEach((pipe) {
    bindPipeDestroyLifecycleCallbacks(pipe.meta, pipe.instance, pipe.view);
  });
}

class ViewBinderVisitor implements TemplateAstVisitor {
  final CompileView view;
  num _nodeIndex = 0;
  ViewBinderVisitor(this.view);

  dynamic visitBoundText(BoundTextAst ast, dynamic context) {
    var node = this.view.nodes[_nodeIndex++];
    bindRenderText(ast, node, this.view);
    return null;
  }

  dynamic visitText(TextAst ast, dynamic context) {
    _nodeIndex++;
    return null;
  }

  dynamic visitNgContent(NgContentAst ast, dynamic context) {
    return null;
  }

  dynamic visitElement(ElementAst ast, dynamic context) {
    var compileElement = (view.nodes[_nodeIndex++] as CompileElement);
    var listeners =
        collectEventListeners(ast.outputs, ast.directives, compileElement);

    // Collect directive output names.
    final directiveOutputs = new Set<String>();
    for (var directiveAst in ast.directives) {
      directiveOutputs.addAll(directiveAst.directive.outputs.values);
    }

    // Determine which listeners must be registered as stream subscriptions,
    // and which must be registered as event handlers.
    final eventListeners = <CompileEventListener>[];
    final streamListeners = <CompileEventListener>[];
    for (var listener in listeners) {
      if (directiveOutputs.contains(listener.eventName)) {
        streamListeners.add(listener);
      } else {
        eventListeners.add(listener);
      }
    }

    bindRenderInputs(ast.inputs, compileElement);
    bindRenderOutputs(eventListeners);
    var index = -1;
    ast.directives.forEach((directiveAst) {
      index++;
      var directiveInstance = compileElement.directiveInstances[index];
      bindDirectiveInputs(directiveAst, directiveInstance, compileElement);
      bindDirectiveDetectChangesLifecycleCallbacks(
          directiveAst, directiveInstance, compileElement);
      bindDirectiveHostProps(directiveAst, directiveInstance, compileElement);
      bindDirectiveOutputs(directiveAst, directiveInstance, streamListeners);
    });
    templateVisitAll(this, ast.children, compileElement);
    // afterContent and afterView lifecycles need to be called bottom up
    // so that children are notified before parents
    index = -1;
    ast.directives.forEach((directiveAst) {
      index++;
      var directiveInstance = compileElement.directiveInstances[index];
      bindDirectiveAfterContentLifecycleCallbacks(
          directiveAst.directive, directiveInstance, compileElement);
      bindDirectiveAfterViewLifecycleCallbacks(
          directiveAst.directive, directiveInstance, compileElement);
      bindDirectiveDestroyLifecycleCallbacks(
          directiveAst.directive, directiveInstance, compileElement);
    });
    return null;
  }

  dynamic visitEmbeddedTemplate(EmbeddedTemplateAst ast, dynamic context) {
    var compileElement = (this.view.nodes[this._nodeIndex++] as CompileElement);
    // The template parser ensures these listeners are for directive outputs,
    // so they all must be registered as stream subscriptions.
    var eventListeners =
        collectEventListeners(ast.outputs, ast.directives, compileElement);
    var index = -1;
    ast.directives.forEach((directiveAst) {
      index++;
      var directiveInstance = compileElement.directiveInstances[index];
      bindDirectiveInputs(directiveAst, directiveInstance, compileElement);
      bindDirectiveDetectChangesLifecycleCallbacks(
          directiveAst, directiveInstance, compileElement);
      bindDirectiveOutputs(directiveAst, directiveInstance, eventListeners);
      bindDirectiveAfterContentLifecycleCallbacks(
          directiveAst.directive, directiveInstance, compileElement);
      bindDirectiveAfterViewLifecycleCallbacks(
          directiveAst.directive, directiveInstance, compileElement);
      bindDirectiveDestroyLifecycleCallbacks(
          directiveAst.directive, directiveInstance, compileElement);
    });
    bindView(compileElement.embeddedView, ast.children);
    return null;
  }

  dynamic visitAttr(AttrAst ast, dynamic context) {
    return null;
  }

  dynamic visitDirective(DirectiveAst ast, dynamic context) {
    return null;
  }

  dynamic visitEvent(BoundEventAst ast, dynamic context) {
    var eventTargetAndNames = context as Map<String, BoundEventAst>;
    assert(eventTargetAndNames != null);
    return null;
  }

  dynamic visitReference(ReferenceAst ast, dynamic context) {
    return null;
  }

  dynamic visitVariable(VariableAst ast, dynamic context) {
    return null;
  }

  dynamic visitDirectiveProperty(
      BoundDirectivePropertyAst ast, dynamic context) {
    return null;
  }

  dynamic visitElementProperty(BoundElementPropertyAst ast, dynamic context) {
    return null;
  }
}
