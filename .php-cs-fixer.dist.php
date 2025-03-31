<?php

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__ . '/src')
    ->exclude('vendor');

$config = new PhpCsFixer\Config();

return $config
    ->setRiskyAllowed(true)
    ->setRules([
        // 行末ブラケットに
        'braces' => [
            'position_after_functions_and_oop_constructs' => 'same',
            'position_after_control_structures' => 'same',
            'position_after_anonymous_constructs' => 'same',
        ],

        // コメント・PHPDoc
        'align_multiline_comment' => ['comment_type' => 'phpdocs_only'],
        'no_empty_phpdoc' => true,
        'no_superfluous_phpdoc_tags' => ['allow_mixed' => true],
        'phpdoc_align' => ['align' => 'vertical', 'tags' => ['param']],
        'phpdoc_line_span' => ['property' => 'single'],
        'phpdoc_trim' => true,
        'phpdoc_trim_consecutive_blank_line_separation' => true,

        // 配列・インデント・スペース
        'array_indentation' => true,
        'array_syntax' => ['syntax' => 'short'],
        'binary_operator_spaces' => ['default' => 'single_space'],
        'cast_spaces' => ['space' => 'single'],
        'concat_space' => ['spacing' => 'one'],
        'indentation_type' => true,
        'unary_operator_spaces' => true,

        // 空行・ホワイトスペース
        'blank_line_after_namespace' => true,
        'blank_line_after_opening_tag' => true,
        'blank_line_before_statement' => ['statements' => ['declare']],
        'no_extra_blank_lines' => true,
        'no_trailing_whitespace' => true,
        'no_trailing_whitespace_in_comment' => true,
        'no_whitespace_in_blank_line' => true,
        'single_blank_line_at_eof' => true,

        // インポート・名前空間
        'fully_qualified_strict_types' => true,
        'global_namespace_import' => [
            'import_constants' => true,
            'import_functions' => true,
            'import_classes' => null,
        ],
        'no_unused_imports' => true,
        'ordered_imports' => [
            'imports_order' => ['class', 'function', 'const'],
            'sort_algorithm' => 'alpha'
        ],
        'single_import_per_statement' => true,

        // 関数・演算子・構文
        'declare_strict_types' => true,
        'elseif' => true,
        'logical_operators' => true,
        'native_constant_invocation' => ['scope' => 'namespaced'],
        'native_function_invocation' => ['scope' => 'namespaced', 'include' => ['@all']],
        'new_with_braces' => ['named_class' => true, 'anonymous_class' => false],
        'return_type_declaration' => ['space_before' => 'one'],
        'strict_param' => true,

        // タグまわり
        'no_closing_tag' => true,
    ])
    ->setFinder($finder)
    ->setIndent("    ") // インデントをタブに指定（デフォはスペース）
    ->setLineEnding("\n"); // 改行コード LF
