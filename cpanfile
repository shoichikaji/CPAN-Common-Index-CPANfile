requires 'perl', '5.008001';
requires 'CPAN::Common::Index';
requires 'Capture::Tiny';
requires 'Module::CPANfile';
requires 'OrePAN2::Indexer';
requires 'OrePAN2::Injector';
requires 'parent';


on 'test' => sub {
    requires 'Test::More', '0.98';
};

